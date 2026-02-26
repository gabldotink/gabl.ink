# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

section(){
  section_state="$1"
  section_section="$2"

  printf '[section %s] %s\n' "${section_state}" "${section_section}" >&2
}
