#!/bin/sh
# SPDX-License-Identifier: CC0-1.0

export POSIXLY_CORRECT

script="$0"
id="$1"
export script id

# todo: “readlink” dependency
index="$(readlink --canonicalize "$(dirname "$script")/../../../..")"
export index

extract(){
  key="$1"
  export key
  jq --raw-output --monochrome-output ".$key" "$index/$id/info.json"
}
export extract

printf '<!DOCTYPE html>
<html lang="%s"
      xmlns="http://www.w3.org/1999/xhtml" xml:lang="%s">
<!-- SPDX-License-Identifier: CC-BY-4.0 -->
<!-- ============= wrap lines at 72 printed characters ============= -->
  <head>
    <meta charset="utf-8"/>
    <meta name="viewport"
          content="width=device-width,initial-scale=1"/>
    <title>%s</title>
    <meta name="robots"
          content="index,follow"/>
    <style>

    </style>
  </head>
  <body>

  </body>
</html>
' "$(extract language.full)" \
  "$(extract language.full)" \
  "$(extract title.text)"

exit 0
