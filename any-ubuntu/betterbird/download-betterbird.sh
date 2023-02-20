#!/bin/sh
BASE_URL="https://www.betterbird.eu/downloads/"
HREFS="$(curl -s "${BASE_URL}"|grep -o 'href="[^"]*"')"
BETTERBIRD_VERSION="$(echo "${HREFS}"|grep "LinuxArchive.*de.linux-x86_64"|grep -o "betterbird-[^-]*-"|cut -d- -f2|sort -V|tail -1)"
RELATIVE_URL="$(echo "${HREFS}"|grep "LinuxArchive.*${BETTERBIRD_VERSION}.*de.linux-x86_64"|tail -1|cut -d'=' -f2|tr -d '"')"
URL="${BASE_URL}${RELATIVE_URL}"
TARBZ2="$(basename "${RELATIVE_URL}")"
if [ -s "${HOME}/Downloads/${TARBZ2}" ]; then
  echo >&2 "Bereits vorhanden: '${URL}'"
  RC=1
#  echo "${HOME}/Downloads/thunderbird-${THUNDERBIRD_VERSION}.tar.bz2"
#  RC=0
else
  echo >"${HOME}/Downloads/${TARBZ2}.urls" "${URL}"
  echo >&2 "Lade herunter '${URL}'"
  curl -s "${URL}" >"${HOME}/Downloads/${TARBZ2}"
  echo "${HOME}/Downloads/${TARBZ2}"
  RC=0
fi
exit "${RC}"
