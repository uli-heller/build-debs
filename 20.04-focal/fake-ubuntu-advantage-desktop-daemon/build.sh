#!/bin/sh
# ./build 0.1dp02
VERSION="$1"

set -e

PACKAGE="$(sed -n -e "/^Package:/ s/^Package:\s*// p" "src/DEBIAN/control")"

# Anpassungen: ./DEBIAN/control
sed -i \
  -e "s/^Version: .*$/Version: ${VERSION}/"\
  "src/DEBIAN/control"

dpkg-deb -b src "${PACKAGE}_${VERSION}_all.deb"
