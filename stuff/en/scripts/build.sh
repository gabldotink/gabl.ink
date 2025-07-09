#!/bin/sh
# SPDX-License-Identifier: CC-BY-4.0

# This script requires jq to be installed in your PATH.

script="$0"

index="$(dirname -- "$script")/.."

items="$(find "$index" -type f -name data.json)"

for i in $items;do
  type="$(jq -Mr -- .type "$i")"

  if [ "$type" = comic_series ];then
    continue
  fi

  printf '<!DOCTYPE html>'

  id="$(jq -Mr -- .id "$i")"
  language="$(jq -Mr -- .language "$i")"
  copyright_license="$(jq -Mr -- .copyright.license[0] "$i")"
  dict="$index/dictionary"

  # Quotation marks escape hyphens and periods in key names.
  language_bcp_47_full="$(jq -Mr -- ".\"$language\".bcp_47.full" "$dict/language.json")"
  language_dir="$(jq -Mr -- ".\"$language\".dir" "$dict/language.json")"

  printf '<html lang="%s" dir="%s" xmlns="http://www.w3.org/1999/xhtml" xml:lang="%s">\n' "$language_bcp_47_full" "$language_dir" "$language_bcp_47_full"

  copyright_license_spdx="$(jq -Mr -- ".\"$copyright_license\".spdx" "$dict/copyright_license.json")"

  printf '<!-- SPDX-License-Identifier: %s -->\n' "$copyright_license_spdx"

  printf '<head>'
  printf '<meta charset="utf-8">'
  printf '<meta name="viewport" content="width=device-width,initial-scale=1"/>'

  title_text="$(jq -Mr -- .title.text "$i")"

  printf '<title>gabl.ink – %s</title>' "$title_text"

  description_text="$(jq -Mr -- .description.text "$i")"

  printf '<meta name="description" content="%s"/>' "$description_text"
  printf '<meta name="robots" content="index,follow"/>'
  printf '<link rel="canonical" href="https://gabl.ink/index/%s/" hreflang="en-US" type="text/html"/>' "$id"

  if [ "$type" = comic_page ];then
    up_directories=4

    if [ -n "$(jq -Mr -- .location.volume "$i")" ];then
      up_directories="$((up_directories-1))"
    fi

    if [ -n "$(jq -Mr -- .location.chapter "$i")" ];then
      up_directories="$((up_directories-1))"
    fi

    up_directories_path="$(
      # shellcheck disable=SC2034
      for n in $(seq 1 "$up_directories");do
        printf ../
      done
    )"

    series="$(jq -Mr -- .location.series "$i")"

    printf '<link rel="preload" href="%sstyle/global.css" as="style" hreflang="en-US" type="text/css"/>' "$up_directories_path"
    printf '<link rel="preload" href="%sstyle/comic_page_%s.css" as="style" hreflang="en-US" type="text/css"/>' "$up_directories_path" "$series"
    printf '<link rel="stylesheet" href="%sstyle/global.css" hreflang="en-US" type="text/css"/>' "$up_directories_path"
    printf '<link rel="stylesheet" href="%sstyle/comic_page_%s.css" hreflang="en-US" type="text/css"/>' "$up_directories_path" "$series"

    if [ "$up_directories" = 4 ];then
      volume="$(jq -Mr -- .location.volume "$i")"
      chapter="$(jq -Mr -- .location.chapter "$i")"
      first_page="$(jq -Mr -- .pages.first.string "$index/$series/$volume/$chapter/data.json")"
      last_page="$(jq -Mr -- .pages.last.string "$index/$series/$volume/$chapter/data.json")"
    elif [ "$up_directories" = 3 ];then
      chapter="$(jq -Mr -- .location.chapter "$i")"
      first_page="$(jq -Mr -- .pages.first.string "$index/$series/$chapter/data.json")"
      last_page="$(jq -Mr -- .pages.last.string "$index/$series/$chapter/data.json")"
    elif [ "$up_directories" = 2 ];then
      first_page="$(jq -Mr -- .pages.first.string "$index/$series/data.json")"
      last_page="$(jq -Mr -- .pages.last.string "$index/$series/data.json")"
    fi

    previous_page="$(jq -Mr -- .location.previous.string "$i")"
    next_page="$(jq -Mr -- .location.next.string "$i")"

    # TODO: Warn if previous_page is null but this is not first_page.
    if   [ "$previous_page" = null ];then
      # This is the first page, so no prefetches are needed.
      true
    elif [ "$first_page" != "$(jq -Mr -- .location.page.string "$i")" ] ||
         [ "$first_page" != "$previous_page" ];then
      printf '<link rel="prefetch" href="../%s/" hreflang="%s" type="text/html"/>' "$first_page" "$language_bcp_47_full"
      printf '<link rel="prev prefetch" href="../%s/" hreflang="%s" type="text/html"/>' "$previous_page" "$language_bcp_47_full"
    elif [ "$first_page"  = "$previous_page" ];then
      printf '<link rel="prev prefetch" href="../%s/" hreflang="%s" type="text/html"/>' "$previous_page" "$language_bcp_47_full"
    fi

    # TODO: Warn if next_page is null but this is not last_page.
    if   [ "$next_page" = null ];then
      # This is the last page, so no prefetches are needed.
      true
    elif [ "$last_page" != "$(jq -Mr -- .location.page.string "$i")" ] ||
         [ "$last_page" != "$next_page" ];then
      printf '<link rel="next prefetch" href="../%s/" hreflang="%s" type="text/html"/>' "$next_page" "$language_bcp_47_full"
      printf '<link rel="prefetch" href="../%s/" hreflang="%s" type="text/html"/>' "$last_page" "$language_bcp_47_full"
    elif [ "$last_page"  = "$next_page" ];then
      printf '<link rel="next prefetch" href="../%s/" hreflang="%s" type="text/html"/>' "$next_page" "$language_bcp_47_full"
    fi

    language_ogp_full="$(jq -Mr -- ".\"$language\".ogp.full" "$dict/language.json")"

    printf '<meta property="og:type" content="article"/>'
    printf '<meta property="og:title" content="%s"/>' "$title_text"
    printf '<meta property="og:description" content="%s"/>' "$description_text"
    printf '<meta property="og:site_name" content="gabl.ink"/>'
    printf '<meta property="og:url" content="https://gabl.ink/index/%s"/>' "$id"
    printf '<meta property="og:image" content="https://gabl.ink/index/%s/image.png"/>' "$id"
    printf '<meta property="og:locale" content="%s"/>' "$language_ogp_full"

    printf '</head>'
  fi
done
