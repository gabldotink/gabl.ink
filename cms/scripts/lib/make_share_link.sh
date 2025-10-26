# shellcheck shell=sh
# shellcheck disable=SC2154
# SPDX-License-Identifier: CC0-1.0
# Do not run or source this file! It is meant to be sourced by ../build.sh only.

make_share_link() {
  make_share_link_id="$1"
  [ -n "${config_share_skip}" ] &&
    if printf ' %s ' "${config_share_skip}" | grep -Fqe " ${make_share_link_id} ";then
      return 0
    fi
  make_share_link_platform="$2"
  make_share_link_base="$3"
  make_share_link_text_param="$4"
  make_share_link_url_param="$5"
  make_share_link_hashtag_param="$6"
  make_share_link_text="$(printf '%s' "$7"|jq -Rr -- @uri)"
  make_share_link_hashtag="$(printf '%s' "$8"|jq -Rr -- @uri)"

  printf '<li id="share_links_%s">' "${make_share_link_id}"
  printf '<a rel="external" href="%s' "${make_share_link_base}"

  if [ "${make_share_link_id}" = reddit ];then
    make_share_link_start_param='&amp;'
  else
    make_share_link_start_param='?'
  fi

  if [ -n "${make_share_link_text_param}" ];then
    printf '%s%s=%s' "${make_share_link_start_param}" "${make_share_link_text_param}" "${make_share_link_text}"
    [ "${make_share_link_start_param}" = '?' ] &&
      make_share_link_start_param='&amp;'
  fi

  if [ -n "${make_share_link_url_param}" ];then
    printf '%s%s=%s' "${make_share_link_start_param}" "${make_share_link_url_param}" "$(printf '%s' "${canonical}"|jq -Rr -- @uri)"
    [ "${make_share_link_start_param}" = '?' ] &&
      make_share_link_start_param='&amp;'
  fi

  [ -n "${make_share_link_hashtag_param}" ] &&
    printf '%s%s=%s' "${make_share_link_start_param}" "${make_share_link_hashtag_param}" "${make_share_link_hashtag}"

  printf '">Share with %s</a></li>' "${make_share_link_platform}"
}
