# shellcheck shell=sh
# shellcheck disable=SC2154
# SPDX-License-Identifier: CC0-1.0
# Do not run or source this file! It is meant to be sourced by ../build.sh only.

make_validate_link() {
  make_validate_link_id="$1"
  [ -n "${config_validate_skip}" ] &&
    printf ' %s ' "${config_validate_skip}" | grep -Fqe " ${make_validate_link_id} " &&
      return 0
  make_validate_link_platform="$2"
  make_validate_link_base="$3"
  make_validate_link_format="$4"
  make_validate_link_url="$(printf '%s' "${canonical}"|jq -Rr -- @uri)"

  printf '<li id="validate_links_%s">' "${make_validate_link_id}"
  printf '<a rel="external" href="%s' "${make_validate_link_base}${make_validate_link_url}"

  printf '">Validate with %s' "${make_validate_link_platform}"
  if [ -n "${make_validate_link_format}" ];then
    printf ' as %s</a></li>' "${make_validate_link_format}"
  else
    printf '</a></li>'
  fi
}
