#!/bin/sh
DEB="$1"

set -e

[ -s "${DEB}" ] || { echo >&2 "${DEB} gibt es nicht"; exit 1; }

getDpkgParameter () {
  (
    f="$1"
    p="$2"
    dpkg-deb -I "${f}"\
    |grep "^\s*${p}:"\
    |sed -e "s/^[^:]*: //" -e "s/^\s*//" -e "s/\s*$//"
  )
}

VERSION="$(getDpkgParameter "${DEB}" "Version")"
ARCHITECTURE="$(getDpkgParameter "${DEB}" "Architecture")"
PACKAGE="$(getDpkgParameter "${DEB}" "Package")"

dpkg-deb -x "${DEB}" "${VERSION}"
dpkg-deb -e "${DEB}" "${VERSION}/DEBIAN"

VERSIONDP="${VERSION}dp02"

rm -rf "${VERSIONDP}"
cp -a "${VERSION}" "${VERSIONDP}"

find .

# Anpassungen: ./opt/google/chrome/cron/google-chrome
#(
#echo "#!/bin/sh"
#echo "exit 0"
#) >"${VERSIONDP}/opt/google/chrome/cron/google-chrome"

# Anpassungen: ./DEBIAN/postinst
#sed -i \
#  -e 's/repo_add_once="true"/repo_add_once="false"/'\
#  -e 's/repo_reenable_on_distupgrade="true"/repo_reenable_on_distupgrade="false"/'\
#  "${VERSIONDP}/DEBIAN/postinst"

# Anpassungen: ./DEBIAN/control
sed -i \
  -e "s/${VERSION}/${VERSIONDP}/"\
  "${VERSIONDP}/DEBIAN/control"

# ./etc/cron.daily/google-chrome: Löschen
#rm -f "${VERSIONDP}/etc/cron.daily/google-chrome"

dpkg-deb -b "${VERSIONDP}" "${PACKAGE}_${VERSIONDP}_${ARCHITECTURE}.deb"
