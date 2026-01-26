# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0
# Do not run or source this file! It is meant to be sourced by ../build.sh only.

jq_r(){
  jq_r_k="$1"
  jq_r_f="$2"
  jq -r -- ".${jq_r_k}" "${jq_r_f}"
}
