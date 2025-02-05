#!/bin/sh

set -e
#set -x

# firefox-102.1.0esr.tar.bz2
# firefox-135.0esr.tar.xz
FIREFOX_TAR_XZ="$1"
BUILDID="$2"
test -z "${BUILDID}" && BUILDID=uh

VERSION="$(basename "${FIREFOX_TAR_XZ}" .tar.xz|cut -d"-" -f2-)"

for c in alien fakeroot; do
  which "${c}" >/dev/null || { echo >&2 "'${c}' nicht gefunden!"; exit 1; }
done

#CODENAME="$(cat /etc/lsb-release|grep CODENAME|cut -d= -f2)"
#test -z "${CODENAME}" && CODENAME="$(cat /etc/lsb-release|grep RELEASE|cut -d= -f2)"
CODENAME=any
NEW_VERSION="${VERSION}+${BUILDID}01~${CODENAME}0"
NEW_VERSION1="1:${NEW_VERSION}"

rm -rf opt usr
rm -rf firefox
xz -cd "${FIREFOX_TAR_XZ}"|tar -xf -
mkdir opt
mv firefox opt
(
  cd build-addons
  find . -name "*~"|xargs -r rm -f
  tar cf - .
)|tar xf -

FIREFOX_DP_TAR_XZ="$(echo "${FIREFOX_TAR_XZ}"|sed -e 's/.tar.xz$/.dp.tar.xz/')"
tar -cvf - opt usr|bzip2 -c9 >"${FIREFOX_DP_TAR_XZ}"

fakeroot alien -d "${FIREFOX_DP_TAR_XZ}" -v --version=${NEW_VERSION1} -g

cat >>firefox-${NEW_VERSION1}/debian/rules <<EOF
override_dh_strip_nondeterminism:
#
EOF

echo >firefox-${NEW_VERSION1}/debian/changelog~ "firefox (${NEW_VERSION1}) jammy; urgency=low"
tail -n+2 firefox-${NEW_VERSION1}/debian/changelog >>firefox-${NEW_VERSION1}/debian/changelog~
mv firefox-${NEW_VERSION1}/debian/changelog~ firefox-${NEW_VERSION1}/debian/changelog

sed -i -e 's/^Architecture: .*$/Architecture: amd64/' firefox-${NEW_VERSION1}/debian/control
(
  rm -rf *.orig
  rm -rf *.orig.tar.gz
  cd "firefox-${NEW_VERSION1}"
  fakeroot dpkg-buildpackage||exit 0
)
rm -rf opt usr
rm -rf "firefox-${NEW_VERSION1}"
