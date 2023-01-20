#!/bin/sh

BASE_URL="https://download-installer.cdn.mozilla.net/pub/firefox/releases/"
FIREFOX_VERSION="$(curl -s "${BASE_URL}"|grep -o "/pub/firefox/releases/[0-9.]*/"|sort -V|tail -1|xargs basename)"
URL="${BASE_URL}${FIREFOX_VERSION}/linux-x86_64/de/firefox-${FIREFOX_VERSION}.tar.bz2"
if [ -s "${HOME}/Downloads/firefox-${FIREFOX_VERSION}.tar.bz2" ]; then
  echo >&2 "Bereits vorhanden: '${URL}'"
  RC=1
#  echo "${HOME}/Downloads/firefox-${FIREFOX_VERSION}.tar.bz2"
#  RC=0
else
  echo >"${HOME}/Downloads/firefox-${FIREFOX_VERSION}.tar.bz2.urls" "${URL}"
  echo >&2 "Lade herunter '${URL}'"
  curl -s "${URL}" >"${HOME}/Downloads/firefox-${FIREFOX_VERSION}.tar.bz2"
  echo "${HOME}/Downloads/firefox-${FIREFOX_VERSION}.tar.bz2"
  RC=0
fi
exit "${RC}"
