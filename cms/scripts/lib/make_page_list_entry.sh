# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

make_page_list_entry(){
  make_page_list_entry_d="$1"
  make_page_list_entry_s="$(printf '%02d' "$(jq_r location.page "${make_page_list_entry_d}")")"

  set_var_l10n title title "${make_page_list_entry_d}"

  printf '<li>'

  if [ -z "${title_html}" ];then
    [ "${make_page_list_entry_s}" = "${zero_pad_2_page}" ] &&
      printf '<b>'
    printf '<i>no title</i>'
    [ "${make_page_list_entry_s}" = "${zero_pad_2_page}" ] &&
      printf '</b>'
  else
    printf '“'
    if [ "${make_page_list_entry_s}" = "${zero_pad_2_page}" ];then
      printf '<b><cite>'
      printf '%s' "${title_html}"
      printf '</cite></b>”'
    else
      printf '<a href="../'
      printf '%s' "${make_page_list_entry_s}"
      printf '/" hreflang="en-US" type="text/html"><cite>'
      printf '%s' "${title_html}"
      printf '</cite></a>”'
    fi
  fi

  printf '</li>'
}
