# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

parse_lang(){
  # TODO: Support more BCP 47 features (although I won’t use them for a while at least)

  parse_lang_loop=1

  while [ "${parse_lang_loop}" -le 2 ];do
    eval 'parse_lang_'"${parse_lang_loop}"'="$(printf "%s" "${lang}" | cut -d - -f "${parse_lang_loop}")"'
    parse_lang_loop="$((parse_lang_loop+1))"
  done

  if printf '%s' "${parse_lang_1}" | grep -qe '^[a-z]\{2,3\}$';then
    # shellcheck disable=2034
    lang_l="${parse_lang_1}"
  else
    error 'primary language subtag is not valid'
  fi

  if printf '%s' "${parse_lang_2}" | grep -qe '^[A-Z]\{2\}$';then
    # shellcheck disable=2034
    lang_r="${parse_lang_2}"
  else
    error 'region subtag is not valid'
  fi

  lang_s="$(jq -r --arg l "${lang_l}" -- '.[$l].implicit.script' "${dict}/language.json")"

  # shellcheck disable=2034
  lang_d="$(jq -r --arg l "${lang_s}" -- '.[$l].dir' "${dict}/script.json")"

  set_var_l10n lang_l_name_local "\"${lang_l}\".names" "${dict}/language.json"
  set_var_l10n lang_r_name_local "\"${lang_r}\".names" "${dict}/region.json"
  set_var_l10n lang_s_name_local "\"${lang_s}\".names" "${dict}/script.json"
}
