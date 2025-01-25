#!/bin/sh
set -x

test -d "session-manager-plugin" || {
  git clone git@github.com:aws/session-manager-plugin.git
}

(
  cd "session-manager-plugin"
  git fetch --all
)

VERSION="$(cd "session-manager-plugin" && git tag|sort -rV|head -1)"

test -s "session-manager-plugin-${VERSION}.tar.xz" || (
  cd "session-manager-plugin"
  git archive "--prefix=session-manager-plugin-${VERSION}/" "${VERSION}"|xz -c
) >"session-manager-plugin-${VERSION}.tar.xz"

rm -rf "session-manager-plugin-${VERSION}"
xz -cd "session-manager-plugin-${VERSION}.tar.xz" | tar xf -
(
  cd "session-manager-plugin-${VERSION}"
  echo "${VERSION}"|tr -d -c 0-9. >VERSION
  find . -name "*.go"|xargs gofmt -w
  make release
)

cp "session-manager-plugin-${VERSION}/bin/"*deb .
