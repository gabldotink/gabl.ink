# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

say_date(){
  say_date_y="$(eval 'printf "%s" "${'"$1"'_y}"')"
  say_date_m="$(eval 'printf "%s" "${'"$1"'_m}"')"
  say_date_d="$(eval 'printf "%s" "${'"$1"'_d}"')"

  printf '<time datetime="'
  printf '%s-%s-%s' "$(zero_pad 4 "${say_date_y}")" \
                    "$(zero_pad 2 "${say_date_m}")" \
                    "$(zero_pad 2 "${say_date_d}")"
  printf '">'

  set_var_l10n say_date_m "months[$((say_date_m-1))]" "${dict}/month_gregorian.json"

  if [ "${lang_l}" = en ];then
    printf '%s ' "${say_date_m_html}"
    printf '<span data-ssml-say-as="date" data-ssml-say-as-format="d">%s</span>, ' "${say_date_d}"
    if   [ "${#say_date_y}" -lt 4 ] &&
         [ "${say_date_y}" -ne 0 ];then
      printf '<abbr title="anno Domini">AD</abbr> <span data-ssml-say-as="date" data-ssml-say-as-format="y">%s</span>' "${say_date_y}"
    elif [ "${say_date_y}" -eq 0 ];then
      printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">1</span> <abbr title="before Christ">BC</abbr>'
    else
      printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">%s</span>' "${say_date_y}"
    fi
  elif [ "${lang_l}" = fr ];then
    if [ "${say_date_d}" -eq 1 ];then
      printf 1er
    else
      printf '<span data-ssml-say-as="date" data-ssml-say-as-format="d">%s</span>' "${say_date_d}"
    fi
    printf ' %s ' "${say_date_m_html}"
    if [ "${say_date_y}" -eq 0 ];then
      printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">1</span> <abbr title="avant Jésus‐Christ">av. J.‐C.</abbr>'
    else
      printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">%s</span>' "${say_date_y}"
    fi
  fi

  printf '</time>'
}
