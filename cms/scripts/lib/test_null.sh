# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0
# Do not run or source this file! It is meant to be sourced by ../build.sh only.

test_null(){
  # shellcheck disable=2034
  test_null_var="$1"
  eval '[ "${'"${test_null_var}"'}" = null ]'
}
