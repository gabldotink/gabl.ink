# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

config_set(){
  [ -f "$cms/scripts/config.json" ] ||
    cat "$cms/scripts/config_d.json" > "$cms/scripts/config.json"
  # booleans/strings
  for c in exit_on_warning exit_nonzero_with_warnings lang_default;do
    eval "config_$c"'="$(jq_r "$c" "$cms/scripts/config.json")"'
  done
  # arrays
  for d in validate_skip share_skip;do
    eval "config_$d"'="$(jq_r "$d[]" "$cms/scripts/config.json"|sort -u|tr -s "\n" " ")"'
  done
}
