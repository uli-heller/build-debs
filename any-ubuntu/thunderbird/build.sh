#!/bin/sh

set -e
#set -x

# thunderbird-102.1.0esr.tar.bz2
THUNDERBIRD_TAR_BZ2="$1"
VERSION="$(basename "${THUNDERBIRD_TAR_BZ2}" .tar.bz2|cut -d"-" -f2-)"

for c in alien fakeroot; do
  which "${c}" >/dev/null || { echo >&2 "'${c}' nicht gefunden!"; exit 1; }
done

#CODENAME="$(cat /etc/lsb-release|grep CODENAME|cut -d= -f2)"
#test -z "${CODENAME}" && CODENAME="$(cat /etc/lsb-release|grep RELEASE|cut -d= -f2)"
CODENAME=any
NEW_VERSION="${VERSION}-0uh01~${CODENAME}0"
NEW_VERSION1="1:${NEW_VERSION}"

rm -rf opt usr
rm -rf thunderbird
bzip2 -cd "${THUNDERBIRD_TAR_BZ2}"|tar -xf -
mkdir opt
mv thunderbird opt
(
  cd build-addons
  find . -name "*~"|xargs -r rm -f
  tar cf - .
)|tar xf -

THUNDERBIRD_DP_TAR_BZ2="$(echo "${THUNDERBIRD_TAR_BZ2}"|sed -e 's/.tar.bz2$/.dp.tar.bz2/')"
tar -cvf - opt usr|bzip2 -c9 >"${THUNDERBIRD_DP_TAR_BZ2}"

fakeroot alien -d "${THUNDERBIRD_DP_TAR_BZ2}" -v --version=${NEW_VERSION1} -g

cat >>thunderbird-${NEW_VERSION1}/debian/rules <<EOF
override_dh_strip_nondeterminism:
#
EOF

echo >thunderbird-${NEW_VERSION1}/debian/changelog~ "thunderbird (${NEW_VERSION1}) jammy; urgency=low"
tail -n+2 thunderbird-${NEW_VERSION1}/debian/changelog >>thunderbird-${NEW_VERSION1}/debian/changelog~
mv thunderbird-${NEW_VERSION1}/debian/changelog~ thunderbird-${NEW_VERSION1}/debian/changelog

sed -i -e 's/^Architecture: .*$/Architecture: amd64/' thunderbird-${NEW_VERSION1}/debian/control
(
  rm -rf *.orig
  rm -rf *.orig.tar.gz
  cd "thunderbird-${NEW_VERSION1}"
  fakeroot dpkg-buildpackage||exit 0
)
rm -rf opt usr
rm -rf "thunderbird-${NEW_VERSION1}"
