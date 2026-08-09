# shellcheck shell=sh
# SPDX-License-Identifier: CC0-1.0

test_unset(){
  eval '[ -z "${'"$1"'+x}" ]'
}
