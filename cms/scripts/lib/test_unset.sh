# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

test_unset(){
  eval '[ -z "${'"$1"'+x}" ]'
}
