# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

make_share_link(){
  [ -n "$config_share_skip" ] &&
    printf '%s\n' "$config_share_skip"|grep "-Fqe^$1$" &&
      return 0
  set_var_l10n make_share_link_name "\"$1\".name" "$dict/share_link.json"
  make_share_link_base="$(jq -r --arg l "$1" '.[$l].base' "$dict/share_link.json")"
  make_share_link_title_param="$(jq -r --arg l "$1" '.[$l].title' "$dict/share_link.json")"
  make_share_link_url_param="$(jq -r --arg l "$1" '.[$l].url' "$dict/share_link.json")"
  make_share_link_text_param="$(jq -r --arg l "$1" '.[$l].text' "$dict/share_link.json")"
  make_share_link_hashtag_param="$(jq -r --arg l "$1" '.[$l].hashtag' "$dict/share_link.json")"
  make_share_link_title="$(jq -rn --arg s "$2" '$s|@uri')"
  make_share_link_text="$(jq -rn --arg t "$3" '$t|@uri')"
  make_share_link_hashtag="$(jq -rn --arg h "$4" '$h|@uri')"

  printf '<li id="share_links_%s">' "$1"
  printf '<a rel="external" href="%s' "$make_share_link_base"

  if [ "$1" = reddit ];then
    make_share_link_start_param='&amp;'
  else
    make_share_link_start_param='?'
  fi

  if ! test_null make_share_link_title_param &&
     [ -n "$make_share_link_title" ];then
    printf '%s%s=%s' "$make_share_link_start_param" "$make_share_link_title_param" "$make_share_link_title"
    [ "$make_share_link_start_param" = '?' ] &&
      make_share_link_start_param='&amp;'
  fi

  if ! test_null make_share_link_url_param;then
    printf '%s%s=%s' "$make_share_link_start_param" "$make_share_link_url_param" "$(printf '%s' "$canonical"|jq -Rr @uri)"
    [ "$make_share_link_start_param" = '?' ] &&
      make_share_link_start_param='&amp;'
  fi

  if ! test_null make_share_link_text_param &&
     [ -n "$make_share_link_text" ];then
    printf '%s%s=%s' "$make_share_link_start_param" "$make_share_link_text_param" "$make_share_link_text"
    [ "$make_share_link_start_param" = '?' ] &&
      make_share_link_start_param='&amp;'
  fi

  if ! test_null make_share_link_hashtag_param &&
     [ -n "$make_share_link_hashtag" ];then
    printf '%s%s=%s' "$make_share_link_start_param" "$make_share_link_hashtag_param" "$make_share_link_hashtag"
  fi

  printf '">%s' "$(printf_l10n share_with)"

  printf '%s' "$make_share_link_name_html"

  printf '</a></li>'
}
