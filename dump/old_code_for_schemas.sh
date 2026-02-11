# shellcheck shell=sh
# Do not run or source this file!

# This would be easier if I didn’t insist on POSIX compliance
#dicts="$(find "${dict}" -path "${dict}" -o -type d -prune -o -type f -exec basename '{}' ';')"
dicts=disclaimer.json

printf '[section start] dictionaries\n' >&2

for id in ${dicts};do
  (
    printf '[start] %s\n' "${id}" >&2

    # shellcheck disable=2030
    tmpfile="$(mktemp)"

    trap \
      'rm -f -- "${tmpfile}" >/dev/null 2>&1' \
    INT EXIT

    {
      printf '{'
    
      # shellcheck disable=2016
      printf '"$schema":"https://json-schema.org/draft/2020-12/schema",'
      # shellcheck disable=2016
      printf '"$id":"https://gabl.ink/cms/dictionaries/schemas/%s",' "${id}"
      # shellcheck disable=2016
      printf '"$comment":"SPDX-License-Identifier: CC0-1.0",'
      printf '"type":"object",'

      for k in $(jq -r -- 'to_entries[]|select(.value|has("key_format"))|.key' "${dict}/schemas_templates/${id}");do
        if [ "$(jq -r --arg k "${k}" '.[$k].key_format' "${dict}/schemas_templates/${id}")" = key ];then
          printf '"^[A-Za-z0-9._-]$":{'
        else
          error 'key_format is not key'
        fi

          if [ "$(jq -r --arg k "${k}" '.[$k].content.format' "${dict}/schemas_templates/${id}")" = localized ];then
            printf '"type":"object",'

            printf '"patternProperties":{'

            printf '"^[a-z]{2,3}(-([A-Z]{2}|[0-9]{3}))?$":{'

            printf '"type":"object",'
            printf '"properties":{'

            printf '"ascii":{'
              printf '"type":"string",'
              printf '"pattern":"^[ -~]+$"'
            printf '},'

            printf '"filename":{'
              printf '"type":"string",'
              printf '"pattern":"^[A-Za-z0-9_-]{250}$"'
            printf '},'

            printf '"html":{'
              printf '"type":"string",'
              printf '"pattern":"^.+$"'
            printf '},'

            printf '"id":{'
              printf '"type":"string",'
              printf '"pattern":"^.+$"'
            printf '},'

            printf '"text":{'
              printf '"type":"string",'
              printf '"pattern":"^.+$"'
            printf '}'

            printf '}'

            printf '}'

            printf '}'
          fi

          printf '}'

          printf '}'

      # the indentation is messed up somewhere, I don’t care though
      done

      printf '}\n'
    } > "${tmpfile}"

    if [ "$(jq -Sc -- . "${tmpfile}")" != "$(cat -- "${dict}/schemas/${id}")" ];then
      jq -Sc -- . "${tmpfile}" > "${dict}/schemas/${id}"
    fi

    rm -f -- "${tmpfile}" >/dev/null 2>&1

    printf '[done] %s\n' "${id}" >&2
  ) &
done

wait

printf '[section done] dictionaries\n' >&2
