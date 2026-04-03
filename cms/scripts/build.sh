#!/bin/sh
# SPDX-License-Identifier: CC0-1.0

export POSIXLY_CORRECT
LC_ALL=C

trap 'printf "Exiting. No changes were made.\n"' INT EXIT

script="$0"

deps='[ basename cat cmp cut dirname find grep jq mktemp printf realpath rm sh sort tput uniq xargs'

for c in $deps;do
  if command -v -- "$c" >/dev/null 2>&1;then
    commands_v="$commands_v $c"
  fi
done

for r in $deps;do
  case "$commands_v " in
    *" $r "*)
      : ;;
    *)
      printf -- \
'This script requires the following commands to be available: %s
You have the following commands available:%s
Please install missing commands.
' "$deps" "$commands_v" >&2
      exit 1
  esac
done

# Note: These operands are not specified by POSIX, but I consider these POSIX‐compatible for this purpose; that is, if they are unsupported the styling will be ignored, and if they are supported only some text decorations will change.

usage(){
  trap - INT EXIT
  printf -- 'Usage: %s [-h] [-u] [-w] [-q|-s] [-i <dir>] [-f <dir>]\n' "$script"
}

usage_long(){
  usage
  printf -- 'Version: dev

This script generates the gabl.ink website.

This script requires the following programs to be available:
  %s
You have no problems there.

Options:
  -h (help)       Show help
  -u (usage)      Show short usage
  -w (where)      Print the location of the script
  -m (monochrome) Disable styling
  -i (items)      Directories of items to build, space/newline separated (defaults to all items)
  -f (find)       Directories containing items to build, space/newline separated (defaults to all items)
  -q (quiet)      Suppress all stderr output (including errors!)
  -s (silent)     Same as -q

-i finds “[value]/data.json”, while -f recursively searches for “data.json” files. Note that the script will not function correctly if any of the file paths contain spaces, tabs, or newlines. There are currently few checks to make sure these are valid, so be careful.

©\302\2402024–2026 gabl.ink
License: CC0\302\2401.0 Universal (CC0\302\2401.0)
%s%shttps://creativecommons.org/publicdomain/zero/1.0/deed.en%s
' "$deps" "$tput_underline" "$tput_blue" "$tput_reset"
}

# This, most notably, prevents find from getting confused if the dirname starts with a hyphen‑minus. Better to be paranoid than to get one of your files replaced with a JoeRunner PNG. Actually, that would be pretty awesome.
case "$script" in
  /*|./*|../*)
    : ;;
  *)
    script="./$script"
esac

scripts="$(dirname -- "$script")"
lib="$scripts/lib"

# shellcheck source-path=./lib
for f in "$lib/"*.sh;do
  . "$f"
done

tput_underline="$(tput smul 2>/dev/null||:)"
tput_italic="$(tput sitm 2>/dev/null||:)"
tput_bold="$(tput bold 2>/dev/null||:)"
tput_red="$(tput setaf 1 2>/dev/null||:)"
tput_yellow="$(tput setaf 3 2>/dev/null||:)"
tput_blue="$(tput setaf 4 2>/dev/null||:)"
tput_reset="$(tput sgr0 2>/dev/null||:)"

# TODO: This ensures all options are processed before printing anything, but time could still be wasted if, for example, both -h and -f are used. However, this has zero chance of actually doing anything dangerous, so I’ll leave it for now.
while getopts :mqs-huwi:f: o;do
  case "$o" in
    m)
      unset tput_underline tput_italic tput_bold tput_red tput_yellow tput_blue tput_reset ;;
    q|s)
      exec 2>/dev/null ;;
    w)
      help=w ;;
    u)
      help=u ;;
    h)
      help=h ;;
    i)
      for q in $OPTARG;do
        case "$q" in
          /*|./*|../*)
            : ;;
          *)
            q="./$q"
        esac
        items="$items $q/data.json"
      done ;;
    f)
      items="$items $(find $OPTARG -type f -name data.json)" ;;
    '?')
      unknowns="$unknowns -$OPTARG" ;;
    *)
      usage >&2
      exit 2
  esac
done

unset o

if [ -n "$unknowns" ];then
  printf '%s\n' "$unknowns"|grep '-qve [A-Za-z0-9]' &&
    printf 'One or more options are illegal.\n' >&2
  printf 'Unknown option' >&2
  [ "${#unknowns}" -gt 1 ] &&
    printf s >&2
  printf ':%s\n' "$unknowns" >&2
  exit 2
fi

unset unknowns

if [ "$help" = h ];then
  usage_long
  exit 0
elif [ "$help" = u ];then
  usage
  exit 0
elif [ "$help" = w ];then
  realpath -e "$script"
  exit 0
fi

unset help

exit_if

shift "$((OPTIND-1))"

# We aren’t allowed to do this. I still don’t fully understand why
#unset OPTIND

if [ "$#" -ne 0 ];then
  usage >&2
  exit 2
fi

cms="$scripts/.."
dict="$cms/dictionaries"
index="$cms/../index"
encyclopedia="$index/encyclopedia"

config_set

if [ -z "$items" ];then
  #items="$(find "$index" -type f -name data.json)"
  items="$(find "$index" -type f -path "$index/jrco_beta/*/data.json")"
fi

for j in $items;do
  if [ ! -f "$j" ];then
    err error "File not found: “$j”. Remember spaces, tabs, and newlines are not allowed as part of file paths."
  fi
done

exit_if

# TODO: More robust checks for if file paths contain whitespace. In the meantime, I just have to be careful.
# The if loop above will find most problems anyway, so we will assume we’re good to normalize the list for now.
items="$(printf '%s\n' "$items"|tr ' \t' '\n'|uniq)"

# Last chance to error out before we actually do anything
exit_if

trap - INT EXIT

err info 'section start: items'

for i in $items;do (
  type="$(jq_r type "$i")"
  id="$(jq_r id "$i")"

  if [ "$type" != comic_page ];then
    err info skip
    continue
  fi

  err info 'item start'

  ## This continue only exits this subshell, but that’s fine, since the subshell is the whole loop
  #if [ "$type" = comic_series ];then
  #  err info skip
  #  # shellcheck disable=2106
  #  continue
  #fi

  lang_original="$(jq_r lang_original "$i")"

  for lang in $(jq_r langs[] "$index/$id/data.json");do (
    err info 'lang start'

    tmpfile="$(mktemp)"

    trap 'rm -f -- "$tmpfile" >/dev/null 2>&1' INT EXIT

    parse_lang

    copyright_license="$(jq_r copyright.license[0] "$i")"
    # Literal quotation marks should be used when inserting variables into jq (hyphen‐minuses can cause issues).
    # shellcheck disable=2016
    set_var_l10n copyright_license_abbr "\"$copyright_license\".abbr" "$dict/copyright_license.json"
    # shellcheck disable=2016
    set_var_l10n copyright_license_url "\"$copyright_license\".url" "$dict/copyright_license.json"
    copyright_license_spdx="$(jq -r --arg l "$copyright_license" '.[$l].spdx' "$dict/copyright_license.json")"
    # shellcheck disable=2016
    set_var_l10n copyright_license_title "\"$copyright_license\".title" "$dict/copyright_license.json"
    copyright_year_first="$(jq_r copyright.year.first "$i")"
    copyright_year_last="$(jq_r copyright.year.last "$i")"
    set_var_l10n description description "$i"
    disclaimer="$(jq_r 'disclaimer[0]' "$i")"
    set_var_l10n title title "$i"

    canonical="https://gabl.ink/index/$id/$lang/"

    # For now, the below is to add later.
    # For future reference: Each video should have a WebM (VP9/Opus) and MP4 (H.264/AAC) version.
    # WebM should be preferred due to being free (libre), and MP4 should be provided as a fallback for compatibility.
    # In case of a video, image.png should act as a thumbnail.
    [ -f "$index/$id/$lang/video.webm" ] &&
      video_exists=true

    [ -f "$index/$id/$lang/cc.vtt" ] &&
      captions_exists=true

    [ -f "$index/$id/$lang/subs.vtt" ] &&
      subs_exists=true

    [ "$(jq_r tooltip "$i")" != null ] &&
      tooltip_exists=true

    {
      printf '<!DOCTYPE html>\n'
      printf -- '<!-- SPDX-License-Identifier: %s -->\n' "$copyright_license_spdx"

      # shellcheck disable=2154
      printf -- '<html lang="%s" dir="%s" xmlns="http://www.w3.org/1999/xhtml" xml:lang="%s">' \
             "$lang" "$lang_d" "$lang"

      printf '<head><meta charset="utf-8"/><meta name="viewport" content="width=device-width,initial-scale=1"/>'

      printf -- '<title>%s</title>' "$(printf_l10n html_title "$title_text")"

      printf -- '<meta name="description" content="%s"/>' "$description_text"
      printf '<meta name="robots" content="index,follow"/>'
      printf -- '<link rel="canonical" href="%s" hreflang="%s" type="text/html"/>' "$canonical" "$lang_bcp_47_full"

      if [ "$type" = comic_page ];then
        first_published_d="$(jq_r first_published.d "$i")"
        first_published_m="$(jq_r first_published.m "$i")"
        first_published_y="$(jq_r first_published.y "$i")"
        chapter="$(jq_r location.chapter "$i")"
        next="$(jq_r location.next "$i")"
        page="$(jq_r location.page "$i")"
        prev="$(jq_r location.previous "$i")"
        series="$(jq_r location.series "$i")"
        set_var_l10n series_hashtag hashtag "$index/$id/../data.json"
        set_var_l10n series_title title "$index/$id/../data.json"
        if [ "$tooltip_exists" = true ];then
          set_var_l10n tooltip tooltip "$i"
        fi
        volume="$(jq_r location.volume "$i")"

        # Determine how many directories deep from the series the page is
        up_directories=4

        test_null volume &&
          up_directories="$((up_directories-1))"

        test_null chapter &&
          up_directories="$((up_directories-1))"

        styles="$(
          # ShellCheck warns “n” is unused, but that’s intentional
          # shellcheck disable=2034
          for n in $(count_from 1 "$up_directories");do
            printf ../
          done
          printf ../../cms/styles
        )"

        if   [ "$up_directories" -eq 2 ];then
          container=series
        elif [ "$up_directories" -eq 3 ];then
          container=chapter
        elif [ "$up_directories" -eq 4 ];then
          container=volume
        else
          err error 'up_directories is not 2, 3, or 4'
        fi

        printf -- '<link rel="preload" href="%s/global.css" as="style" hreflang="zxx" type="text/css"/>' \
               "$styles"
        printf -- '<link rel="preload" href="%s/comic_page.css" as="style" hreflang="zxx" type="text/css"/>' \
               "$styles"
        printf -- '<link rel="stylesheet" href="%s/global.css" hreflang="zxx" type="text/css"/>' \
               "$styles"
        printf -- '<link rel="stylesheet" href="%s/comic_page.css" hreflang="zxx" type="text/css"/>' \
               "$styles"

        printf -- '<link rel="external license" href="%s"/>' "$copyright_license_url_id"

        if   [ "$up_directories" -eq 3 ];then
          chapter="$(jq_r location.chapter "$i")"
        elif [ "$up_directories" -eq 4 ];then
          volume="$(jq_r location.volume "$i")"
          chapter="$(jq_r location.chapter "$i")"
        fi

        container_first="$(jq_r pages.first "$index/$id/../data.json")"
        container_last="$(jq_r pages.last "$index/$id/../data.json")"

        if test_null prev;then
          # This is the first page, so no prefetches are needed.
          :
        elif [ "$container_first" != "$page" ] ||
             [ "$container_first" != "$prev" ];then
          printf -- '<link rel="prefetch" href="../../%s/" hreflang="%s" type="text/html"/>' \
                 "$(zero_pad 2 container_first)" "$lang_bcp_47_full"
          printf -- '<link rel="prev prefetch" href="../../%s/" hreflang="%s" type="text/html"/>' \
                 "$(zero_pad 2 prev)" "$lang_bcp_47_full"
        elif [ "$container_first" = "$prev" ];then
          printf -- '<link rel="prev prefetch" href="../../%s/" hreflang="%s" type="text/html"/>' \
                 "$(zero_pad 2 prev)" "$lang_bcp_47_full"
        fi

        if test_null next;then
          # This is the last page, so no prefetches are needed.
          :
        elif [ "$container_last" != "$page" ] ||
             [ "$container_last" != "$next" ];then
          printf -- '<link rel="next prefetch" href="../../%s/" hreflang="%s" type="text/html"/>' \
                 "$(zero_pad 2 next)" "$lang_bcp_47_full"
          printf -- '<link rel="prefetch" href="../../%s/" hreflang="%s" type="text/html"/>' \
                 "$(zero_pad 2 container_last)" "$lang_bcp_47_full"
        elif [ "$container_last" = "$next" ];then
          printf -- '<link rel="next prefetch" href="../../%s/" hreflang="%s" type="text/html"/>' \
                 "$(zero_pad 2 next)" "$lang_bcp_47_full"
        fi

        make_og type article
        make_og title "$title_text"
        make_og description "$description_text"
        make_og site_name gabl.ink
        make_og url "$canonical"
        make_og image "${canonical}image.png"
        if [ "$video_exists" = true ];then
          make_og video "${canonical}video.webm"
        fi
        make_og locale "${lang_l}_${lang_r}"

        printf '</head>'

        printf '<body>'
        printf '<header>'
        printf '<a href="https://gabl.ink/" id="gabldotink_logo">'
        printf_l10n gabldotink_logo
        printf '</a></header>'
        printf '<div id="panels">'
        printf '<div id="nav_top">'
        printf '<h1 id="nav_top_title">'
        printf_l10n page_title_html "$title_html"
        printf '</h1>'

        test_null container_first ||
          set_var_l10n container_first_title title "$index/$id/../$(zero_pad 2 container_first)/data.json"

        test_null prev ||
          set_var_l10n prev_title title "$index/$id/../$(zero_pad 2 prev)/data.json"

        test_null next ||
          set_var_l10n next_title title "$index/$id/../$(zero_pad 2 next)/data.json"

        test_null container_last ||
          set_var_l10n container_last_title title "$index/$id/../$(zero_pad 2 container_last)/data.json"

        make_nav_buttons top

        printf '</div>'

        printf '<div id="comic_page_'

        # TODO: Edge case: no captions
        if [ "$video_exists" = true ];then
          printf 'video"><video controls="" poster="./image.png" preload="auto"'
          if [ "$tooltip_exists" = true ];then
            printf -- ' title="%s"' "$tooltip_text"
          fi
          printf '>'
          printf '<source src="./video.webm" type="video/webm"/>'
          if [ "$captions_exists" = true ];then
            printf '<track kind="captions" '
            printf -- 'label="%s (%s) (CC)" ' "$lang_l_name_local_text" "$lang_r_name_local_text"
            printf -- 'src="./cc.vtt" srclang="%s"/>' "$lang"
          fi
          if [ "$subs_exists" = true ];then
            printf '<track default="" kind="subtitles" '
            printf -- 'label="%s (%s)" ' "$lang_l_name_local_text" "$lang_r_name_local_text"
            printf -- 'src="./subs.vtt" srclang="%s"/>' "$lang"
          fi
          printf '<p>'
          printf_l10n video_not_supported "$lang" "$series_title_filename" "$title_filename"
          printf '</p>'
          printf '</video></div>'
        else
          printf 'image"><picture'
          [ "$tooltip_exists" = true ] &&
            printf -- ' title="%s"' "$tooltip_text"
          printf '>'
          printf '<img src="./image.png" alt="'
          printf_l10n see_transcript
          printf '"/></picture></div>'
        fi

        printf '<div id="nav_bottom">'

        make_nav_buttons bottom

        printf '<nav id="nav_bottom_list">'

        printf '<details id="nav_bottom_list_root">'

        printf '<summary>'

        # TODO: Support lower containers (volumes and chapters).

        if [ "$container" = series ];then
          printf_l10n series_title_html "$series_title_html"
        fi

        printf_l10n comma_page "$page"

        printf_l10n page_title_html "$title_html"

        printf '</summary>'

        printf '<ol id="nav_bottom_list_pages">'

        find "$index/$id/.." -type f -path "$index/$id/../*/data.json"|sort -n|xargs '-I{}' -- sh -c -- '[ -n "$1" ]&&set -x
page="$2"
cms="$3"
lib="$cms/scripts/lib"
dict="$cms/dictionaries"
lang="$4"
for f in config_get config_set err jq_r make_page_list_entry parse_lang printf_l10n set_var_l10n test_null zero_pad
do . "$lib/$f.sh"
done
config_set
parse_lang
make_page_list_entry "$5"' \
          sh "$(printf '%s\n' "$-"|grep -Fex)" "$page" "$cms" "$lang" {}

        printf '</ol></details></nav></div>'

        printf '<details id="comic_transcript">'

        printf -- '<summary>%s</summary>' "$(printf_l10n transcript_name)"

        printf '<table id="comic_transcript_table">'

        printf '<thead><tr>'
        printf -- '<th scope="col">%s</th>' "$(printf_l10n transcript_speaker)"
        printf -- '<th scope="col">%s</th>' "$(printf_l10n transcript_text)"
        printf '</tr></thead>'

        for l in $(jq_r 'transcript.lines|to_entries|.[].key' "$i");do
          # shellcheck disable=2016
          l_h="$(jq -r --argjson l "$l" '.transcript.lines[$l].h' "$i")"
          set_var_l10n l_d "transcript.lines[$l].d" "$i"

          l_h_type="$(jq_r type "$encyclopedia/$l_h/data.json")"
          [ "$l_h_type" = character ] ||
            [ "$l_h_type" = meta_character ] ||
              err error 'l_h_type is not character or meta_character'
          if [ "$(jq_r name "$encyclopedia/$l_h/data.json")" = null ];then
            unset_var_l10n l_h_label
          else
            set_var_l10n l_h_label name.label "$encyclopedia/$l_h/data.json"
            test_null l_h_label &&
              set_var_l10n l_h_label name.given "$encyclopedia/$l_h/data.json"
          fi

          printf '<tr>'
          # shellcheck disable=2154
          printf '<th scope="row">%s</th>' "$l_h_label_html"
          # shellcheck disable=2154
          printf '<td><p>%s</p></td>' "$l_d_html"
          printf '</tr>'
        done

        printf '</table></details>'

        printf -- '<p id="first_published">%s%s</p>' "$(printf_l10n first_published)" "$(say_date first_published)"

        printf '<article id="post_'

        for p in $(jq_r 'post|to_entries|.[].key' "$i");do
          set_var_l10n post_content "post.[$p].content" "$i"
          post_date_d="$(jq -r --argjson p "$p" '.post[$p].date.d' "$i")"
          post_date_m="$(jq -r --argjson p "$p" '.post[$p].date.m' "$i")"
          post_date_y="$(jq -r --argjson p "$p" '.post[$p].date.y' "$i")"

          printf -- '%s-%s-%s">' "$(zero_pad 4 post_date_y)" "$(zero_pad 2 post_date_m)" "$(zero_pad 2 post_date_d)"

          printf '<h2>%s</h2>' "$(say_date post_date)"

          printf -- '%s' "$post_content_html"

          printf '</article>'
        done

        printf '<details id="share_links">'
        printf '<summary>%s</summary>' "$(printf_l10n share_this_page)"
        printf '<ul>'

        make_share_link email \
                       "$(
                          printf -- 'gabl.ink: _%s_: “%s”' "$series_title_text" "$title_text"
                        )" \
                       "$(
                          printf -- 'From https://gabl.ink/ : %s' "$canonical"
                        )"

        make_share_link sms '' \
                       "$(
                          printf -- 'gabl.ink: _%s_: “%s” %s' "$series_title_text" "$title_text" "$canonical"
                        )"

        make_share_link x '' \
                       "$(
                          printf -- 'gabl.ink @gabldotink: _%s_: “%s”' "$series_title_text" "$title_text"
                        )" \
                       "gabldotink,$series_hashtag_id"

        make_share_link reddit \
                       "$(
                          printf -- 'gabl.ink: _%s_: “%s”' "$series_title_text" "$title_text"
                        )"

        make_share_link facebook

        make_share_link telegram '' \
                       "$(
                          printf -- 'gabl.ink: _%s_: “%s” #gabldotink #%s' "$series_title_text" "$title_text" "$series_hashtag_id"
                        )"

        make_share_link bluesky '' \
                       "$(
                          printf -- 'gabl.ink @gabl.ink: _%s_: “%s” %s #gabldotink #%s' "$series_title_text" "$title_text" "$canonical" "$series_hashtag_id"
                        )"

        make_share_link whatsapp '' \
                       "$(
                          printf -- 'gabl.ink: _%s_: “%s” %s' "$series_title_text" "$title_text" "$canonical"
                        )"

        make_share_link mastodon '' \
                       "$(
                          printf -- 'gabl.ink @gabldotink@mstdn.party: _%s_: “%s” #gabldotink #%s' "$series_title_text" "$title_text" "$series_hashtag_id"
                        )"

        make_share_link threads '' \
                       "$(
                          printf -- 'gabl.ink: _%s_: “%s” #gabldotink #%s' "$series_title_text" "$title_text" "$series_hashtag_id"
                        )"

        make_share_link truth_social '' \
                       "$(
                          printf -- 'gabl.ink: _%s_: “%s” #gabldotink #%s' "$series_title_text" "$title_text" "$series_hashtag_id"
                        )"

        make_share_link gab '' \
                       "$(
                          printf -- 'gabl.ink: _%s_: “%s” #gabldotink #%s' "$series_title_text" "$title_text" "$series_hashtag_id"
                        )"

        make_share_link vk \
                       "$(
                          printf -- 'gabl.ink: _%s_: “%s”' "$series_title_text" "$title_text"
                        )" \
                       "$(
                          printf -- 'From https://gabl.ink/ : %s #gabldotink #%s' "$canonical" "$series_hashtag_id"
                        )"

        printf '</ul></details>'

        printf '<details id="validate_links">'
        printf -- '<summary>%s</summary>' "$(printf_l10n validate_this_page)"
        printf '<ul>'

        make_validate_link vnu
        make_validate_link w3c
      fi

      printf '</ul></details>'

      printf '<footer><p><span class="nw">'
      printf -- '<abbr title="%s">©</abbr>&#160;' "$(printf_l10n copyright)"
      printf -- '<time data-ssml-say-as="date" data-ssml-say-as-format="y">%s</time>' "$copyright_year_first"
      ! test_null copyright_year_last &&
        printf -- '–<time data-ssml-say-as="date" data-ssml-say-as-format="y">%s</time>' "$copyright_year_last"
      printf '</span> <span translate="no" data-ssml-phoneme-alphabet="ipa" data-ssml-phoneme-ph="ˈɡæbəl dɒt ˈɪŋk">gabl.ink</span></p>'

      printf -- '<p>%s<a rel="external license" href="%s">' "$(printf_l10n license)" "$copyright_license_url_id"
      printf -- '<cite>%s</cite>' "$copyright_license_title_html"
      ! test_null copyright_license_abbr &&
        printf -- ' (<cite><abbr>%s</abbr></cite>)' "$copyright_license_abbr_html"
      printf '</a></p>'

      if ! test_null disclaimer;then
        set_var_l10n disclaimer "\"$disclaimer\"" "$dict/disclaimer.json"
        printf -- '<p>%s%s</p>' "$(printf_l10n disclaimer)" "$disclaimer_html"
      fi

      printf '</footer></div></body></html>\n'

      exit_if
    } > "$tmpfile"

    exit_if

    flush_from_tmp "$tmpfile" "$index/$id/$lang/index.html"

    err info 'lang done'
    ) &
  done
  wait
  unset lang
  err info 'item done'
  ) &
done
wait

err info 'section done: items'

trap - INT EXIT

[ "$warned" = true ] &&
  [ "$config_exit_nonzero_with_warnings" = true ] &&
    exit 2

exit_if

exit 0
