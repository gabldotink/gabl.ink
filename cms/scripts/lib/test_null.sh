# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

test_null(){
  eval '[ "${'"$1"'}" = null ]'
}
