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
      xmlns="http://www.w3.org/1999/xhtml" xml:lang="%s">
<!-- SPDX-License-Identifier: %s -->
<!-- ============= wrap lines at 72 printed characters ============= -->
  <head>
    <meta charset="utf-8"/>
    <meta name="viewport"
          content="width=device-width,initial-scale=1"/>
    <title>gabl.ink – %s</title>
    <meta name="robots"
          content="index,follow"/>
    <link rel="canonical"
          href="https://gabl.ink/index/%s/index.html"
          hreflang="%s"/>
    <!-- todo: internationalize this link -->
    <link rel="stylesheet"
     href="https://gabl.ink/index/en/meta/includes/css/global/index.css"
          hreflang="%s"/>
    <meta property="og:title"
          content="%s"/>
    <meta property="og:type"
          content="article"/>
    <meta property="og:url"
          content="https://gabl.ink/index/%s/index.html"/>
    <!-- todo: work with “image” arrays (or make new property for a
       - “preferred” image) -->
    <meta property="og:image"
          content="https://gabl.ink/index/%s/image%s"/>
  </head>
  <body>

  </body>
</html>
' "$(j language.text)" \
  "$(j language.text)" \
  "$(j license)" \
  "$(j title.text)" \
  "$(j id.full)" \
  "$(j language.full)" \
  "$(j title.text)" \
  "$(j id.full)" \
  "$(j id.full)" \
  "$(j format.image)"
fi

exit 0
