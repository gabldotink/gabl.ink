# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

jq_r(){
  jq -r -- ".$1" "$2"
}
