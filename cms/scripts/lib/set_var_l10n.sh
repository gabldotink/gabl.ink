# shellcheck shell=sh
# SPDX-License-Identifier: CC0-1.0

set_var_l10n(){
  # TODO: Allow using values from other regions (e.g. en-GB for en-US)
  for o in "$lang" "$lang_l" mul zxx e;do
    if [ "$o" = e ];then
      err e 'There is no suitable value for a variable'
      break
    fi

    for t in equal html id printf text;do
      eval " ${1}_$t"'="$(jq -r --arg o "$o" --arg t "$t" -- ".$2"'"'"'.[$o].[$t]'"'"' "$3")"' >/dev/null 2>&1
      test_null "${1}_$t" &&
        unset -- "${1}_$t"
    done

    if ! test_unset "${1}_equal" &&
       [ "$o" != "$(eval 'printf "%s" "$'"$1"'_equal"')" ];then
        eval 'lang="$'"$1"'_equal" set_var_l10n "$1" "$2" "$3"'
        break
    fi

    # mutually exclusive

    if ! test_unset "${1}_id";then
      unset -- "${1}_html" "${1}_printf" "${1}_text"
      break
    fi

    if ! test_unset "${1}_printf";then
      unset -- "${1}_html" "${1}_text"
      break
    fi

    # text to html
    test_unset "${1}_html" &&
      ! test_unset "${1}_text" &&
        eval " $1"'_html="$'"$1"'_text"'

    # finish if html is set
    test_unset "${1}_html" ||
      break
  done
}
