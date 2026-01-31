# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

jq_r(){
  jq_r_k="$1"
  jq_r_f="$2"
  jq -r -- ".${jq_r_k}" "${jq_r_f}"
}
