# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

say_date(){
  say_date_y="$(eval 'printf "%s" "$'"$1"'_y"')"
  say_date_m="$(eval 'printf "%s" "$'"$1"'_m"')"
  say_date_d="$(eval 'printf "%s" "$'"$1"'_d"')"

  if [ "$say_date_y" -gt 0 ];then
    printf '<time datetime="'
    printf '%s-%s-%s' "$(zero_pad 4 say_date_y)" \
                      "$(zero_pad 2 say_date_m)" \
                      "$(zero_pad 2 say_date_d)"
    printf '">'
  fi

  set_var_l10n say_date_m "months[$((say_date_m-1))]" "$dict/month_gregorian.json"

  if [ "$lang_l" = en ];then
    printf '%s\302\240' "$say_date_m_html"
    printf '<span data-ssml-say-as="date" data-ssml-say-as-format="d">%s</span>, ' "$say_date_d"
    if   [ "$say_date_y" -lt 100 ] &&
         [ "$say_date_y" -gt 0 ];then
      printf '<abbr title="anno Domini">AD</abbr>\302\240<span data-ssml-say-as="date" data-ssml-say-as-format="y">%s</span>' "$say_date_y"
    elif [ "$say_date_y" -le 0 ];then
      printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">%s</span>\302\240<abbr title="before Christ">BC</abbr>' "$((1+$((-say_date_y))))"
    else
      printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">%s</span>' "$say_date_y"
    fi
  elif [ "$lang_l" = fr ];then
    if [ "$say_date_d" -eq 1 ];then
      printf 1er
    else
      printf '<span data-ssml-say-as="date" data-ssml-say-as-format="d">%s</span>' "$say_date_d"
    fi
    printf '\302\240%s ' "$say_date_m_html"
    if   [ "$say_date_y" -lt 100 ] &&
         [ "$say_date_y" -gt 0 ];then
      printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">%s</span>\302\240<abbr title="après Jésus‐Christ">ap.\302\240J.‑C.</abbr>' "$say_date_y"
    elif [ "$say_date_y" -le 0 ];then
      printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">%s</span>\302\240<abbr title="avant Jésus‐Christ">av.\302\240J.‑C.</abbr>' "$((1+$((-say_date_y))))"
    else
      printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">%s</span>' "$say_date_y"
    fi
  elif [ "$lang_l" = es ];then
    printf '<span data-ssml-say-as="date" data-ssml-say-as-format="d">%s</span>\302\240de\302\240' "$say_date_d"
    printf '%s de ' "$say_date_m_html"
    if   [ "$say_date_y" -lt 100 ] &&
         [ "$say_date_y" -gt 0 ];then
      printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">%s</span>\302\240<abbr title="después de Cristo">d.\302\240C.</abbr>' "$say_date_y"
    elif [ "$say_date_y" -le 0 ];then
      printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">%s</span>\302\240<abbr title="antes de Cristo">a.\302\240C.</abbr>' "$((1+$((-say_date_y))))"
    else
      printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">%s</span>' "$say_date_y"
    fi
  else
    err e 'unsupported language for say_date'
  fi

  [ "$say_date_y" -gt 0 ] &&
    printf '</time>'
}
