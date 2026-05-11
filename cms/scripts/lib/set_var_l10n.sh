# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

set_var_l10n(){
  # TODO: Allow using values from other regions (e.g. en-GB for en-US)
  for o in "$lang" "$lang_l" mul "$lang_default" e;do
    if [ "$o" = e ];then
      err e 'There is no suitable value for a variable'
      break
    fi

    for t in filename html id printf text;do
      eval " ${1}_$t"'="$(jq -r --arg o "$o" --arg t "$t" -- ".$2"'"'"'.[$o].[$t]'"'"' "$3")"' >/dev/null 2>&1
      test_null "${1}_$t" &&
        unset -- "${1}_$t"
    done

    # mutually exclusive

    if ! test_unset "${1}_id";then
      unset -- "${1}_filename" "${1}_html" "${1}_printf" "${1}_text"
      break
    fi

    if ! test_unset "${1}_printf";then
      unset -- "${1}_filename" "${1}_html" "${1}_text"
      break
    fi

    # verbatim

    # filename to text
    test_unset "${1}_text" &&
      ! test_unset "${1}_filename" &&
        eval " $1"'_text="$'"$1"'_filename"'

    # text to html
    test_unset "${1}_html" &&
      ! test_unset "${1}_text" &&
        eval " $1"'_html="$'"$1"'_text"'

    # conversions

    # Currently removing ascii from project
    ## convert text to ascii
    #if test_unset "${1}_ascii" &&
    #   ! test_unset "${1}_text";then
    #  eval " ${1}_ascii_tmp='""$(
    #    eval 'printf -- "%s" "$'"$1"'_text"'|
    #      sed "-f$lib/text2ascii.sed"
    #  )'"
    #  eval 'printf -- "%s" "$'"$1"'_ascii_tmp"'|grep '-qe^[ -~]*$' &&
    #    eval " $1"'_ascii="$'"$1"'_ascii_tmp"'
    #  unset -- "${1}_ascii_tmp"
    #fi

    # finish if html is set
    test_unset "${1}_html" ||
      break
  done
}
