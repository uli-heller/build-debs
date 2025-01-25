#!/bin/sh

#
# Stand 2023-02-01 gibt es diese Firefox-Versionen:
# - /pub/firefox/releases/108.0.1/
# - /pub/firefox/releases/108.0.2/
# - /pub/firefox/releases/108.0/
# - /pub/firefox/releases/109.0.1/
# - /pub/firefox/releases/109.0/
# Bei "sort -V" gibt es gibt es die vorgenannte Sortierung.
# Wenn ich nur die Versionsnummern ausschneide und diese
# dann mit "sort -V" sortiere, dann gibt es diese Sortierung:
# - 108.0
# - 108.0.1
# - 108.0.2
# - 109.0
# - 109.0.1
# Also: ERST Versionsnummer ausschneiden, DANN sortieren!
#
BASE_URL="https://download-installer.cdn.mozilla.net/pub/firefox/releases/"
FIREFOX_VERSION="$(curl -s "${BASE_URL}"|grep -o "/pub/firefox/releases/[0-9.]*/"|xargs -n1 basename|sort -V|tail -1)"
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
