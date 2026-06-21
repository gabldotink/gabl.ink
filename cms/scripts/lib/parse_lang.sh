# shellcheck shell=sh
# SPDX-License-Identifier: CC0-1.0

parse_lang(){
  # TODO: Support more BCP 47 features (although I won’t use them for a while at least)

  lang_i="$(jq -nr --arg l "$lang" '$l|ascii_downcase')"

  parse_lang_loop=1

  while [ "$parse_lang_loop" -le 3 ];do
    eval 'parse_lang_'"$parse_lang_loop"'="$(printf "%s" "$lang"|cut -d- "-f$parse_lang_loop")"'
    parse_lang_loop="$((parse_lang_loop+1))"
  done

  if printf '%s\n' "$parse_lang_1"|grep '-qe^[a-z]\{2,3\}$';then
    # shellcheck disable=2034
    lang_l="$parse_lang_1"
    #lang_l_i="$lang_l"
  else
    err e 'Primary language subtag is not valid'
  fi

  if printf '%s\n' "$parse_lang_2"|grep '-qEe^[A-Z]{2}|[0-9]{3}$';then
    # shellcheck disable=2034
    lang_r="$parse_lang_2"
    # shellcheck disable=2034
    lang_r_i="$(jq -nr --arg r "$lang_r" '$r|ascii_downcase')"
  else
    err e 'Region subtag is not valid'
  fi

  if printf '%s\n' "$parse_lang_3"|grep '-qe^[A-Z][a-z]\{3\}$';then
    # shellcheck disable=2034
    lang_s="$parse_lang_3"
    # shellcheck disable=2034
    lang_s_i="$(jq -nr --arg s "$lang_s" '$s|ascii_downcase')"
  elif [ "$(jq -r --arg l "$lang_l" '.[$l].implicit.script' "$dict/language.json")" != null ];then
    # shellcheck disable=2034
    lang_s_i="$(jq -r --arg l "$lang_l" '.[$l].implicit.script' "$dict/language.json")"
    lang_s="$(jq -nr --arg s "$lang_s_i" '$s|(.[:1]|ascii_upcase)+.[1:]')"
  else
    err e 'Script subtag is not valid'
  fi

  # shellcheck disable=2034
  lang_d="$(jq -r --arg s "$lang_s_i" '.[$s].dir' "$dict/script.json")"

  set_var_l10n lang_l_name "\"$lang_l\".name" "$dict/language.json"
  set_var_l10n lang_r_name "\"$lang_r_i\".name" "$dict/region.json"
  set_var_l10n lang_s_name "\"$lang_s_i\".name" "$dict/script.json"

  if [ "$lang_l" = en ]||
     [ "$lang_l" = fr ];then
    # If there’s a way to do this with set_var_l10n, it’s harder than just doing this.
    lang_name_text="$lang_l_name_text ($lang_r_name_text)"
    lang_name_html="$lang_l_name_html ($lang_r_name_html)"
  fi

  # Convert to regional indicators
  lang_r_flag="$(jq -nr --arg r "$lang_r" '$r|explode|map(.-65+127462)|implode')"
}
