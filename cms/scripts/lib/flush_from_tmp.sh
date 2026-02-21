# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

flush_from_tmp(){
  flush_from_tmp_1="$1"
  flush_from_tmp_2="$2"
  if ! cmp -s -- "${flush_from_tmp_1}" "${flush_from_tmp_2}" >/dev/null 2>&1;then
    cat -- "${flush_from_tmp_1}" > "${flush_from_tmp_2}"
  fi
  rm -- "${flush_from_tmp_1}"
}
