# shellcheck shell=sh
# SPDX-License-Identifier: CC0-1.0

make_validate_link(){
  [ -n "$config_validate_skip" ] &&
    printf ' %s \n' "$config_validate_skip"|grep "-Fqe $1 " &&
      return 0
  set_var_l10n make_validate_link_name "\"$1\".name" "$dict/validate_link.json"
  set_var_l10n make_validate_link_format "\"$1\".format" "$dict/validate_link.json"
  make_validate_link_base="$(jq -r --arg l "$1" '.[$l].base' "$dict/validate_link.json")"

  printf '<li id="validate_links_%s">' "$1"
  printf '<a rel="external" href="%s' "$make_validate_link_base$make_share_link_url"
  printf '">%s' "$(printf_l10n validate_with)"
  printf '%s' "$make_validate_link_name_html"
  [ -n "$make_validate_link_format_html" ] &&
    printf '%s%s' "$(printf_l10n validate_as)" "$make_validate_link_format_html"
  printf '</a></li>'
}
