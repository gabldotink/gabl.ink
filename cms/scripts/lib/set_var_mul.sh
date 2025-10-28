# shellcheck shell=sh
# shellcheck disable=SC2154
# SPDX-License-Identifier: CC0-1.0
# Do not run or source this file! It is meant to be sourced by ../build.sh only.

set_var_mul() {
  set_var_mul_name="$1"
  set_var_mul_property="$2"
  set_var_mul_source="$3"

  eval "${set_var_mul_name}"'="$(jq -r -- ".'"${set_var_mul_property}"'.\"${lang}\"" '"${set_var_mul_source}"')"'
  eval "${set_var_mul_name}"'_default="$(jq -r -- ".'"${set_var_mul_property}"'.\"${lang_default}\"" '"${set_var_mul_source}"')"'
  eval "${set_var_mul_name}"'_mul="$(jq -r -- ".'"${set_var_mul_property}"'.mul" '"${set_var_mul_source}"')"'
}
