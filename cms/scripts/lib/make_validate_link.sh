# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0
# Do not run or source this file! It is meant to be sourced by ../build.sh only.

make_validate_link(){
  make_validate_link_id="$1"
  [ -n "${config_validate_skip}" ] &&
    printf ' %s ' "${config_validate_skip}" | grep -Fqe " ${make_validate_link_id} " &&
      return 0
  set_var_l10n make_validate_link_name "\"${make_validate_link_id}\".name" "${dict}/validate_link.json"
  set_var_l10n make_validate_link_format "\"${make_validate_link_id}\".format" "${dict}/validate_link.json"
  make_validate_link_base="$(jq_r "\"${make_validate_link_id}\".base" "${dict}/validate_link.json")"
  make_validate_link_url="$(printf '%s' "${canonical}"|jq -Rr -- @uri)"

  printf '<li id="validate_links_%s">' "${make_validate_link_id}"
  printf '<a rel="external" href="%s' "${make_validate_link_base}${make_validate_link_url}"

  printf '">Validate with '
  if printf '%s' "${make_validate_link_name_html}" | grep -qve '<cite>.*</cite>';then
    printf '<cite>%s</cite>' "${make_validate_link_name_html}"
  else
    printf '%s' "${make_validate_link_name_html}"
  fi
  if [ -n "${make_validate_link_format_html}" ];then
    printf ' as %s</a></li>' "${make_validate_link_format_html}"
  else
    printf '</a></li>'
  fi
}
