# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

set_var_l10n(){
  set_var_l10n_name="$1"
  # shellcheck disable=2034
  set_var_l10n_property="$2"
  # shellcheck disable=2034
  set_var_l10n_source="$3"

  # TODO: Allow using values from other regions (e.g. en-GB for en-US)
  for o in "$lang" "$lang_l" mul "$lang_default" e;do
    if [ "$o" = e ];then
      err error 'There is no suitable value for a variable'
      break
    fi

    for t in ascii filename html id printf text;do
      eval " ${set_var_l10n_name}_$t"'="$(jq -r --arg o "$o" --arg t "$t" -- ".$set_var_l10n_property"'"'"'.[$o].[$t]'"'"' "$set_var_l10n_source")"' >/dev/null 2>&1
      test_null "${set_var_l10n_name}_$t" &&
        unset -- "${set_var_l10n_name}_$t"
    done

    if ! test_unset "${set_var_l10n_name}_id";then
      unset -- "${set_var_l10n_name}_ascii" "${set_var_l10n_name}_filename" "${set_var_l10n_name}_html" "${set_var_l10n_name}_printf" "${set_var_l10n_name}_text"
      break
    fi

    if ! test_unset "${set_var_l10n_name}_printf";then
      unset -- "${set_var_l10n_name}_ascii" "${set_var_l10n_name}_filename" "${set_var_l10n_name}_html" "${set_var_l10n_name}_text"
      break
    fi

    # verbatim filename to ascii
    test_unset "${set_var_l10n_name}_ascii" &&
      test_unset "${set_var_l10n_name}_filename"||
        eval " $set_var_l10n_name"'_ascii="$'"$set_var_l10n_name"'_filename"'

    # verbatim ascii to text
    test_null "${set_var_l10n_name}_text" &&
      test_null "${set_var_l10n_name}_ascii"||
        eval " $set_var_l10n_name"'_text="$'"$set_var_l10n_name"'_ascii"'

    # finish if html is set
    test_unset "${set_var_l10n_name}_html"||
      break

    # verbatim text to html
    # TODO: replace this with conversion due to different handling of character escapes
    if test_unset "${set_var_l10n_name}_text";then
      unset -- "${set_var_l10n_name}_html"
      break
    fi

    # convert ascii to filename
    if test_unset "${set_var_l10n_name}_filename" &&
       test_unset "${set_var_l10n_name}_ascii"||
       eval 'printf "%s\n" "$'"$set_var_l10n_name"'_ascii"'|grep '-qe^[A-Za-z0-9 _-]*$';then
      eval " $set_var_l10n_name"'_filename="'"$(eval 'printf "%s" "$'"$set_var_l10n_name"'_ascii"'|tr ' ' '_')"'"'
    fi
  done
}
