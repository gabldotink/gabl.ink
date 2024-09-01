#!/bin/sh
# SPDX-License-Identifier: CC0-1.0
# ================= wrap lines at 72 printed characters ================

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
  # todo: “jq” dependency
  jq --raw-output --monochrome-output ".$key" "$index/$id/info.json"
}
export extract

id_full="$(extract id.full)"
content="$(extract content)"
language_full="$(extract language.full)"
language_locale="$(extract language.locale)"
title_text="$(extract title.text)"
title_description="$(extract title.description)"
format_image_0="$(extract format.image[0])"
license_0="$(extract license[0])"
export id_full content language_full language_locale title_text title_logline format_image_0 license_0

if \
[ "$content" = comic_page ];then
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
    <meta name="description"
          content="%s"/>
    <meta name="robots"
          content="index,follow"/>
    <link rel="canonical"
          href="https://gabl.ink/index/%s/index.html"
          hreflang="%s"/>
    <!-- todo: internationalize this link -->
    <link rel="stylesheet"
          href="//gabl.ink/index/en/meta/css/global/index.css"
          hreflang="%s"/>
    <meta property="og:type"
          content="article"/>
    <meta property="og:title"
          content="%s"/>
    <meta property="og:description"
          content="%s"/>
    <meta property="og:url"
          content="https://gabl.ink/index/%s/index.html"/>
    <meta property="og:image"
          content="//gabl.ink/index/%s/image%s"/>
    <meta property="og:locale"
          content="%s"/>
  </head>
  <body>

  </body>
</html>
' "$language_full" \
  "$language_full" \
  "$license_0" \
  "$title_text" \
  "$title_description" \
  "$id_full" \
  "$language_full" \
  "$language_full" \
  "$title_text" \
  "$title_description" \
  "$id_full" \
  "$id_full" \
  "$format_image_0" \
  "$language_locale"
fi

exit 0
