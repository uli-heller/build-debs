#!/bin/sh
#set -x
BN="$(basename "$0")"
D="$(dirname "$0")"
T="$(readlink -f "$0")"
TD="$(dirname "${T}")"

TBZ2="$("${TD}/download-thunderbird.sh")" && {
  # Warte, bis der Virencheck durch ist
  for s in $(seq 1 100); do
    sleep 1
    test -r "${TBZ2}" && break
  done
  "${TD}/build-thunderbird.sh" "${TBZ2}" "$1"
}
