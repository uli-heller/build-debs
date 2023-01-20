#!/bin/sh
#set -x
BN="$(basename "$0")"
D="$(dirname "$0")"
T="$(readlink -f "$0")"
TD="$(dirname "${T}")"

TBZ2="$("${TD}/download-thunderbird.sh")" && {
  "${TD}/build-thunderbird.sh" "${TBZ2}" "$1"
}
