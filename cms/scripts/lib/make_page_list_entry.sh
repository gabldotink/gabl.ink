# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

make_page_list_entry(){
  make_page_list_entry_s="$(printf -- '%02d' "$(jq -r .location.page "$1")")"

  set_var_l10n list_title title "$1"

  printf '<li>'

  if [ -z "$list_title_html" ];then
    [ "$make_page_list_entry_s" = "$(zero_pad 2 page)" ] &&
      printf '<b>'
    printf_l10n no_title
    [ "$make_page_list_entry_s" = "$(zero_pad 2 page)" ] &&
      printf '</b>'
  else
    if [ "$make_page_list_entry_s" = "$(zero_pad 2 page)" ];then
      if [ "$lang_l-$lang_r" = en-US ];then
        printf '“<b><cite>'
      elif [ "$lang_l" = fr ];then
        printf '<b><cite class="i">'
      fi
      printf '%s' "$title_html"
      if [ "$lang_l-$lang_r" = en-US ];then
        printf '</cite></b>”'
      elif [ "$lang_l" = fr ];then
        printf '</cite></b>'
      fi
    else
      if [ "$lang_l" = en ];then
        printf '“<a href="../../'
        printf '%s' "$make_page_list_entry_s"
        printf '/%s/" hreflang="%s" type="text/html"><cite>' "$lang" "$lang"
        printf '%s' "$list_title_html"
        printf '</cite></a>”'
      elif [ "$lang_l" = fr ];then
        printf '<a href="../../'
        printf '%s' "$make_page_list_entry_s"
        printf '/%s/" hreflang="%s" type="text/html"><cite class="i">' "$lang" "$lang"
        printf '%s' "$list_title_html"
        printf '</cite></a>'
      fi
    fi
  fi

  printf '</li>'
}
