#!/bin/sh
#set -x
D="$(dirname "$0")"
D="$(cd "${D}" && pwd)"

TXZ="$1"
BUILDID="$2"

BUILD_FOLDER="firefox"
BUILD_SERVER="ubuntu@ubuntu-2004-build"
DST="${BUILD_SERVER}:build/${BUILD_FOLDER}/."

ssh "${BUILD_SERVER}" "cd build; rm -rf '${BUILD_FOLDER}'; mkdir '${BUILD_FOLDER}'"
scp "${TXZ}" "${DST}"
scp -r "${D}/"* "${DST}"
ssh "${BUILD_SERVER}" "cd build/${BUILD_FOLDER}/.; ./build.sh '$(basename ${TXZ})' '${BUILDID}'"
scp "${DST}/firefox*deb" "$(dirname "${TXZ}")"
ssh "${BUILD_SERVER}" "cd build; rm -rf '${BUILD_FOLDER}'"
exit 0
