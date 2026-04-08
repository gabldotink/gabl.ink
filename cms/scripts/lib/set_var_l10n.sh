# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

set_var_l10n(){
  # TODO: Allow using values from other regions (e.g. en-GB for en-US)
  for o in "$lang" "$lang_l" mul "$lang_default" e;do
    if [ "$o" = e ];then
      err error 'There is no suitable value for a variable'
      break
    fi

    for t in ascii filename html id printf text;do
      eval " ${1}_$t"'="$(jq -r --arg o "$o" --arg t "$t" -- ".$2"'"'"'.[$o].[$t]'"'"' "$3")"' >/dev/null 2>&1
      test_null "${1}_$t" &&
        unset -- "${1}_$t"
    done

    if ! test_unset "${1}_id";then
      unset -- "${1}_ascii" "${1}_filename" "${1}_html" "${1}_printf" "${1}_text"
      break
    fi

    if ! test_unset "${1}_printf";then
      unset -- "${1}_ascii" "${1}_filename" "${1}_html" "${1}_text"
      break
    fi

    # verbatim filename to ascii
    test_unset "${1}_ascii" &&
      ! test_unset "${1}_filename" &&
        eval " $1"'_ascii="$'"$1"'_filename"'

    # verbatim ascii to text
    test_unset "${1}_text" &&
      ! test_unset "${1}_ascii" &&
        eval " $1"'_text="$'"$1"'_ascii"'

    # verbatim text to html
    # TODO: replace this with conversion due to different handling of character escapes
    test_unset "${1}_html" &&
      ! test_unset "${1}_text" &&
        eval " $1"'_html="$'"$1"'_text"'
    
    # convert ascii to filename
    if test_unset "${1}_filename" &&
       ! test_unset "${1}_ascii" &&
       eval 'printf "%s\n" "$'"$1"'_ascii"'|grep '-qe^[A-Za-z0-9 _-]*$';then
      eval " $1"'_filename="'"$(eval 'printf "%s" "$'"$1"'_ascii"'|tr ' ' '_')"'"'
    fi

    # finish if html is set
    test_unset "${1}_html" ||
      break
  done
}
