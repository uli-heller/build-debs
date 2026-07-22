#!/bin/sh

#         https://download-installer.cdn.mozilla.net/pub/thunderbird/releases/128.0esr/linux-x86_64/de/thunderbird-128.0esr.tar.bz2
BASE_URL="https://download-installer.cdn.mozilla.net/pub/thunderbird/releases/"
THUNDERBIRD_VERSION="$(curl -s "${BASE_URL}"|grep -o "/pub/thunderbird/releases/[0-9][0-9.]*[^/]*/"|grep -v "/12[579]"|grep -v "/13[0-9]"|grep -v "/14[1-9]"|grep -v "/15[0-6]"|grep -v "b[^/]*/$"|xargs -n1 basename|sort -V|tail -1)"
test -z "${THUNDERBIRD_VERSION}" && {
    echo >&2 "${BN}: Kann aktuelle Thunderbird-Version nicht ermitteln"
    exit 1
}
URL="${BASE_URL}${THUNDERBIRD_VERSION}/linux-x86_64/de/thunderbird-${THUNDERBIRD_VERSION}.tar.xz"
if [ -s "${HOME}/Downloads/thunderbird-${THUNDERBIRD_VERSION}.tar.xz" ]; then
  echo >&2 "Bereits vorhanden: '${URL}'"
  RC=1
#  echo "${HOME}/Downloads/thunderbird-${THUNDERBIRD_VERSION}.tar.xz"
#  RC=0
else
  echo >"${HOME}/Downloads/thunderbird-${THUNDERBIRD_VERSION}.tar.xz.urls" "${URL}"
  echo >&2 "Lade herunter '${URL}'"
  curl -s "${URL}" >"${HOME}/Downloads/thunderbird-${THUNDERBIRD_VERSION}.tar.xz"
  echo "${HOME}/Downloads/thunderbird-${THUNDERBIRD_VERSION}.tar.xz"
  RC=0
fi
exit "${RC}"
