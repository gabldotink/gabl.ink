# shellcheck shell=sh
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
  # make_share_link_url is set once in build.sh
  make_share_link_text="$(jq -rn --arg t "$3" '$t|@uri')"
  make_share_link_hashtag="$(jq -rn --arg h "$4" '$h|@uri')"

  printf '<li id=share_links_%s>' "$1"
  printf '<a rel=external href="%s' "$make_share_link_base"

  if [ "$1" = reddit ];then
    make_share_link_start_param='&amp;'
  else
    make_share_link_start_param='?'
  fi

  for p in title url text hashtag;do
    [ "$make_share_link_start_param" = '?' ] ||
      case "$(eval 'printf %s "$make_share_link_'"$p"'_param"')" in
        [A-Za-z]*)
          make_share_link_start_param='&amp;' ;;
        *)
          make_share_link_start_param='&'
      esac
    if ! test_null "make_share_link_${p}_param" &&
       [ -n "$(eval 'printf %s "$make_share_link_'"$p"'"')" ];then
      printf %s%s=%s "$make_share_link_start_param" \
                     "$(eval 'printf %s "$make_share_link_'"$p"'_param"')" \
                     "$(eval 'printf %s "$make_share_link_'"$p"'"')"
      [ "$make_share_link_start_param" = '?' ] &&
        make_share_link_start_param='&'
    fi
  done

  printf '">%s' "$(printf_l10n share_with)"

  printf %s "$make_share_link_name_html"

  printf '</a></li>'
}
