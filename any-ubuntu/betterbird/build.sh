#!/bin/sh

set -e
#set -x

# betterbird-102.8.0-bb30.de.linux-x86_64.tar.bz2
# betterbird-115.0-bb6.en-US.linux-x86_64.tar.bz2
BETTERBIRD_TAR_BZ2="$1"
BUILDID="$2"
test -z "${BUILDID}" && BUILDID=uh

VERSION="$(basename "${BETTERBIRD_TAR_BZ2}" .linux-x86_64.tar.bz2|sed -e 's/\.[^.]*$//'|cut -d"-" -f2-)"

for c in alien fakeroot; do
  which "${c}" >/dev/null || { echo >&2 "'${c}' nicht gefunden!"; exit 1; }
done

#CODENAME="$(cat /etc/lsb-release|grep CODENAME|cut -d= -f2)"
#test -z "${CODENAME}" && CODENAME="$(cat /etc/lsb-release|grep RELEASE|cut -d= -f2)"
CODENAME=any
NEW_VERSION="${VERSION}+${BUILDID}01~${CODENAME}0"
NEW_VERSION1="1:${NEW_VERSION}"

rm -rf opt usr
rm -rf betterbird
bzip2 -cd "${BETTERBIRD_TAR_BZ2}"|tar -xf -
mkdir opt
mv betterbird opt
(
  cd build-addons
  find . -name "*~"|xargs -r rm -f
  tar cf - .
)|tar xf -

BETTERBIRD_DP_TAR_BZ2="$(echo "${BETTERBIRD_TAR_BZ2}"|sed -e 's/.tar.bz2$/.dp.tar.bz2/')"
tar -cvf - opt usr|bzip2 -c9 >"${BETTERBIRD_DP_TAR_BZ2}"

fakeroot alien -d "${BETTERBIRD_DP_TAR_BZ2}" -v --version=${NEW_VERSION1} -g

cat >>betterbird-${NEW_VERSION1}/debian/rules <<EOF
override_dh_strip_nondeterminism:
#
EOF

echo >betterbird-${NEW_VERSION1}/debian/changelog~ "betterbird (${NEW_VERSION1}) ${CODENAME}; urgency=low"
tail -n+2 betterbird-${NEW_VERSION1}/debian/changelog >>betterbird-${NEW_VERSION1}/debian/changelog~
mv betterbird-${NEW_VERSION1}/debian/changelog~ betterbird-${NEW_VERSION1}/debian/changelog

sed -i -e 's/^Architecture: .*$/Architecture: amd64/' betterbird-${NEW_VERSION1}/debian/control
(
  rm -rf *.orig
  rm -rf *.orig.tar.gz
  cd "betterbird-${NEW_VERSION1}"
  fakeroot dpkg-buildpackage||exit 0
)
rm -rf opt usr
rm -rf "betterbird-${NEW_VERSION1}"
