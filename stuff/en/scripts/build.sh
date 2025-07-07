#!/bin/sh
# SPDX-License-Identifier: CC-BY-4.0

# This script requires jq to be installed in your PATH.

script="$0"
export script

index="$(dirname -- "$script")/../.."
export index

items="$(find "$index" -type f -name data.json)"
export items

for i in $items;do
  export i

  type="$(jq -Mr -- .type "$i")" &
  export type &
  wait

  if [ "$type" = comic_series ];then
    continue
  fi

  printf '<!DOCTYPE html>' &

  id="$(jq -Mr -- .id "$i")" &
  language="$(jq -Mr -- .language "$i")" &
  copyright_license="$(jq -Mr -- .copyright.license[0] "$i")" &
  dict="$index/dictionary" &
  export id language copyright_license dict &
  wait

  language_bcp_47_full="$(jq -Mr -- "$language.bcp_47_full" "$dict/language.json")" &
  language_dir="$(jq -Mr -- "$language.dir" "$dict/language.json")" &
  export language_bcp_47_full language_dir &
  wait

  printf '<html lang="%s" dir="%s" xmlns="http://www.w3.org/1999/xhtml" xml:lang="%s">\n' "$language_bcp_47_full" "$language_dir" "$language_bcp_47_full" &

  copyright_license_spdx="$(jq -Mr -- "$copyright_license.spdx" "$dict/copyright_license.json")" &
  export copyright_license_spdx &
  wait

  printf '<!-- SPDX-License-Identifier: %s -->\n' "$copyright_license_spdx"

  printf '<head>'
  printf '<meta charset="utf-8">'
  printf '<meta name="viewport" content="width=device-width,initial-scale=1"/>' &

  title_text="$(jq -Mr -- title.text "$i")" &
  export title_text &
  wait

  printf '<title>gabl.ink – %s</title>' "$title_text" &

  description_text="$(jq -Mr -- description.text "$description_text")" &
  export description_text &
  wait

  printf '<meta name="description" content="%s"/>' "$description_text"
  printf '<meta name="robots" content="index,follow"/>'
  printf '<link rel="canonical" href="https://gabl.ink/index/%s/" hreflang="en-US" type="text/html"/>' "$id"

  if [ "$type" = comic_page ];then
    up_directories=4 &
    export series up_directories &
    wait

    if [ -n "$(jq -Mr -- .location.volume)" ];then
      up_directories="$((up_directories-1))"
    fi &

    if [ -n "$(jq -Mr -- .location.chapter)" ];then
      up_directories="$((up_directories-1))"
    fi &
    wait

    up_directories_path="$(
      for i in "$(seq 1 "$up_directories")";do
        printf ../
      done
    )" &
    export up_directories_path &
    wait

    printf '<link rel="preload" href="%sglobal.css" hreflang="en-US" as="style" type="text/css"/>' "$up_directories_path"
    printf '<link rel="preload" href="%scomic_page.css" hreflang="en-US" as="style" type="text/css"/>' "$up_directories_path"
    printf '<link rel="stylesheet" href="%sglobal.css" hreflang="en-US"/>' "$up_directories_path"
    printf '<link rel="stylesheet" href="%scomic_page.css" hreflang="en-US"/>' "$up_directories_path" &

    series="$(jq -Mr -- .location.series "$i")" &
    export series &
    wait

    if [ "$up_directories" = 4 ];then
      volume="$(jq -Mr -- .location.volume "$i")" &
      chapter="$(jq -Mr -- .location.chapter "$i")" &
      export volume chapter &
      wait
      first_page="$(jq -Mr -- .pages.first.string "$index/$series/$volume/$chapter/data.json")" &
      last_page="$(jq -Mr -- .pages.last.string "$index/$series/$volume/$chapter/data.json")" &
      export first_page last_page &
      wait
    elif [ "$up_directories" = 3 ];then
      chapter="$(jq -Mr -- .location.chapter "$i")" &
      export chapter &
      wait
      first_page="$(jq -Mr -- .pages.first.string "$index/$series/$chapter/data.json")" &
      last_page="$(jq -Mr -- .pages.last.string "$index/$series/$chapter/data.json")" &
      export first_page last_page &
      wait
    elif [ "$up_directories" = 2 ];then
      first_page="$(jq -Mr -- .pages.first.string "$index/$series/data.json")" &
      last_page="$(jq -Mr -- .pages.last.string "$index/$series/data.json")" &
      export first_page last_page &
      wait
    fi &

    if ! [ "$(jq -Mr -- .location.previous.string "$i")" = null ];then
      previous_page="$(jq -Mr -- .location.previous.string "$i")" &
      export previous_page &
      wait
    fi &

    if ! [ "$(jq -Mr -- .location.next.string "$i")" = null ];then
      next_page="$(jq -Mr -- .location.next.string "$i")" &
      export next_page &
      wait
    fi &
    wait

    if ! [ "$first_page" = "$(jq -Mr -- .location.page.string "$i")" ] ||
       ! [ "$first_page" = "$previous_page" ];then
      printf '<link rel="prefetch" href="../%s/" hreflang="%s" type="text/html"/>' "$first_page" "$language_bcp_47_full"
      printf '<link rel="prev prefetch" href="../%s/" hreflang="%s" type="text/html"/>' "$previous_page" "$language_bcp_47_full"
    elif [ "$first_page" = "$previous_page" ];then
      printf '<link rel="prev prefetch" href="../%s/" hreflang="%s" type="text/html"/>' "$previous_page" "$language_bcp_47_full"
    fi

    if ! [ "$last_page" = "$(jq -Mr -- .location.page.string "$i")" ] ||
       ! [ "$last_page" = "$next_page" ];then
      printf '<link rel="prefetch" href="../%s/" hreflang="%s" type="text/html"/>' "$last_page" "$language_bcp_47_full"
      printf '<link rel="next prefetch" href="../%s/" hreflang="%s" type="text/html"/>' "$next_page" "$language_bcp_47_full"
    elif [ "$last_page" = "$next_page" ];then
      printf '<link rel="next prefetch" href="../%s/" hreflang="%s" type="text/html"/>' "$next_page" "$language_bcp_47_full"
    fi

    language_ogp_full="$(jq -Mr -- "$language.ogp_full" "$dict/language.json")" &
    export language_ogp_full &
    wait

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
