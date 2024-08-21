#!/bin/sh
# SPDX-License-Identifier: CC0-1.0

export POSIXLY_CORRECT

script="$0"
id="$1"
export script id

# todo: “readlink” dependency
index="$(readlink --canonicalize "$(dirname "$script")/../../../..")"
export index

j(){
  key="$1"
  export key
  # todo: “jq” dependency
  jq --raw-output --monochrome-output ".$key" "$index/$id/info.json"
}
export extract

if \
[ "$(jq --raw-output --monochrome-output .type "$index/$id/info.json")"\
  = comic_page ];then
  printf \
'<!DOCTYPE html>
<html lang="%s"
      xmlns="http://www.w3.org/1999/xhtml" xml:lang="%s">' \
  "$(j language.full)"
printf '
<!-- SPDX-License-Identifier: %s -->' "$(j license)"
printf '
<!-- ============= wrap lines at 72 printed characters ============= -->
  <head>
    <meta charset="utf-8"/>
    <meta name="viewport"
          content="width=device-width,initial-scale=1"/>
    <title>%s</title>' "$(j title.text)"
printf '
    <meta name="robots"
          content="index,follow"/>
    <style>

    </style>
  </head>
  <body>

  </body>
</html>\n'
fi

exit 0
