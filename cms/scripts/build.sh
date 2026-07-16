#!/bin/sh
# SPDX-License-Identifier: CC0-1.0

LC_ALL=C
export POSIXLY_CORRECT

trap 'printf "Exiting. No changes were made.\n"' INT EXIT

script="$0"

deps='[ basename cat cmp cut dirname eval find getopts grep jq mkdir mktemp printf realpath rm sh sort tput tr xargs'

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

Arch Linux and derivatives:
  sudo pacman --sync --needed bash coreutils diffutils findutils grep jq ncurses

Debian and derivatives:
  sudo apt update && sudo apt install coreutils dash diffutils findutils grep jq ncurses-bin

macOS (with Homebrew):
  brew install bash coreutils diffutils findutils grep jq ncurses

Termux:
  pkg update && pkg install coreutils dash diffutils findutils grep jq ncurses-utils

Cygwin:
  ./setup-x86_64.exe --quiet-mode --packages=bash,coreutils,diffutils,findutils,grep,jq,ncurses

MSYS2:
  pacman --sync --needed bash coreutils diffutils findutils grep jq ncurses
' "$deps" "$commands_v" >&2
      exit 1
  esac
done

usage(){
  trap - INT EXIT
  printf 'Usage: %s [-h|-u|-w] [-m] [-q|-s] [-i <dir>] [-f <dir>]\n' "$script"
  [ "$1" = - ]||
    printf 'For help: %s -h\n' "$script"
}

usage_long(){
  usage -
  printf -- 'Version: dev

This script generates the gabl.ink website.

This script requires the following programs to be available:
  %s
You have no problems there.

Options:
  -h (help)       Show help
  -u (usage)      Show short usage
  -w (where)      Print the location of the script
  -m (monochrome) Disable text styling
  -q (quiet)      Suppress messages (including errors!)
  -s (silent)     Same as -q
  -i (items)      Directories of items to build, space/newline separated (defaults to all items)
  -f (find)       Directories containing items to build, space/newline separated (defaults to all items)

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

scripts="$(dirname "$script")"
lib="$scripts/lib"

# shellcheck source=./lib/config_set.sh
# shellcheck source=./lib/count_from.sh
# shellcheck source=./lib/err.sh
# shellcheck source=./lib/exit_if.sh
# shellcheck source=./lib/flush_from_tmp.sh
# shellcheck source=./lib/make_nav.sh
# shellcheck source=./lib/make_og.sh
# shellcheck source=./lib/make_page_list_entry.sh
# shellcheck source=./lib/make_share_link.sh
# shellcheck source=./lib/make_validate_link.sh
# shellcheck source=./lib/parse_lang.sh
# shellcheck source=./lib/printf_l10n.sh
# shellcheck source=./lib/say_date.sh
# shellcheck source=./lib/set_var_l10n.sh
# shellcheck source=./lib/test_null.sh
# shellcheck source=./lib/test_unset.sh
# shellcheck source=./lib/unset_var_l10n.sh
# shellcheck source=./lib/zero_pad.sh
for f in config_set count_from err exit_if flush_from_tmp make_nav make_og make_page_list_entry make_share_link make_validate_link parse_lang printf_l10n say_date set_var_l10n test_null test_unset unset_var_l10n zero_pad;do
  . "$lib/$f.sh"
done

# TODO: This ensures all options are processed before printing anything, but time could still be wasted if, for example, both -h and -f are used. However, this has zero chance of actually doing anything dangerous, so I’ll leave it for now.
while getopts :mqs-huwi:f: o;do
  case "$o" in
    h)
      help=h ;;
    u)
      help=u ;;
    w)
      help=w ;;
    m)
      monochrome= ;;
    q|s)
      monochrome=
      silent= ;;
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
      for q in $OPTARG;do
        case "$q" in
          /*|./*|../*)
            : ;;
          *)
            q="./$q"
        esac
        items="$items $(find "$q" -type f -name data.json)"
      done ;;
    '?')
      unknowns="$unknowns -$OPTARG" ;;
    *)
      usage >&2
      exit 2
  esac
done

unset o

if [ -n "$unknowns" ];then
  printf 'Unknown option' >&2
  [ "${#unknowns}" -gt 1 ] &&
    printf s >&2
  printf ':%s\n' "$unknowns" >&2
  usage >&2
  exit 2
fi

unset unknowns

[ -t 2 ] ||
  monochrome=

# Note: These operands are not specified by POSIX, but I consider these POSIX‐compatible for this purpose; that is, if they are unsupported the styling will be ignored, and if they are supported only some text decorations will change.
if test_unset monochrome;then
  tput_underline="$(tput smul 2>/dev/null||:)"
  tput_bold="$(tput bold 2>/dev/null||:)"
  #tput_italic="$(tput sitm 2>/dev/null||:)"
  #tput_black="$(tput setaf 0 2>/dev/null||:)"
  tput_red="$(tput setaf 1 2>/dev/null||:)"
  #tput_green="$(tput setaf 2 2>/dev/null||:)"
  tput_yellow="$(tput setaf 3 2>/dev/null||:)"
  tput_blue="$(tput setaf 4 2>/dev/null||:)"
  tput_magenta="$(tput setaf 5 2>/dev/null||:)"
  tput_cyan="$(tput setaf 6 2>/dev/null||:)"
  #tput_white="$(tput setaf 7 2>/dev/null||:)"
  tput_reset="$(tput sgr0 2>/dev/null||:)"
fi

if [ "$help" = h ];then
  usage_long
  exit 0
elif [ "$help" = u ];then
  usage -
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
index="$cms/../i"
encyclopedia="$index/encyclopedia"

[ -f "$index/data.json" ]||
  err e "File not found: “$index/data.json”. Are you sure this is the gabl.ink directory?"

exit_if

config_set

if [ -z "$items" ];then
  #items="$(find "$index" -type f -name data.json)"
  items="$(find "$index" -type f -path "$index/jrco_beta/*/data.json")"
fi

for j in $items;do
  [ -f "$j" ]||
    err e "File not found: “$j”. Remember spaces, tabs, and newlines are not allowed as part of file paths."
done

exit_if

# TODO: More robust checks for if file paths contain whitespace. In the meantime, I just have to be careful.
# The if loop above will find most problems anyway, so we will assume we’re good to normalize the list for now.
items="$(printf '%s\n' "$items"|tr -s ' \t' '\n'|sort -u)"

# paranoia!!
for j in $items;do
  [ -f "$j" ]||
    err e "File not found: “$j”. Remember spaces, tabs, and newlines are not allowed as part of file paths."
done

if [ ! -f "$scripts/build.lock" ];then
  : > "$scripts/build.lock"
else
  err e "Lock file found: “$scripts/build.lock”. This indicates another instance of the script is already running. If you are sure this is not the case, delete the lock file and try again."
  exit 1
fi

# Last chance to error out before we actually do anything
exit_if

trap - INT EXIT

err i 'section start: items'

for i in $items;do (
  type="$(jq -r .type "$i")"
  id="$(jq -r .id "$i")"

  if [ "$type" != comic_page ];then
    err i skip
    continue
  fi

  err i 'item start'

  ## This continue only exits this subshell, but that’s fine, since the subshell is the whole loop
  #if [ "$type" = comic_series ];then
  #  err i skip
  #  continue
  #fi

  lang_original="$(jq -r .lang_original "$i")"

  for lang in $(jq -r .langs[] "$i");do (
    parse_lang
    
    err i 'lang start'

    [ -d "$index/$id/$lang_i" ]||
      mkdir -p "$index/$id/$lang_i"

    trap 'rm -f -- "$tmpfile"' INT EXIT

    tmpfile="$(mktemp)"

    # Verify the tmpfile was actually created
    [ -f "$tmpfile" ]||
      err e 'Failed to create temporary file'

    exit_if

    langs="$(jq -r .langs[] "$i")"

    copyright_license="$(jq -r .copyright.license[0] "$i")"
    # Literal quotation marks should be used when inserting variables into jq (hyphen‐minuses can cause issues).
    set_var_l10n copyright_license_abbr "\"$copyright_license\".abbr" "$dict/copyright_license.json"
    set_var_l10n copyright_license_url "\"$copyright_license\".url" "$dict/copyright_license.json"
    copyright_license_spdx="$(jq -r --arg l "$copyright_license" '.[$l].spdx' "$dict/copyright_license.json")"
    set_var_l10n copyright_license_title "\"$copyright_license\".title" "$dict/copyright_license.json"
    copyright_year_first="$(jq -r .copyright.year.first "$i")"
    copyright_year_last="$(jq -r .copyright.year.last "$i")"
    set_var_l10n description description "$i"
    disclaimer="$(jq -r .disclaimer[0] "$i")"
    set_var_l10n title title "$i"

    canonical="https://gabl.ink/i/$id/$lang_i/"

    # For now, the below is to add later.
    # For future reference: Each video should have a WebM (VP9/Opus) and MP4 (H.264/AAC) version.
    # WebM should be preferred due to being free (_libre_), and MP4 should be provided as a fallback for compatibility.
    # In case of a video, image.png should act as a thumbnail.
    [ -f "$index/$id/$lang_i/video.webm" ] &&
      video_exists=

    [ -f "$index/$id/$lang_i/cc.vtt" ] &&
      captions_exists=

    [ -f "$index/$id/$lang_i/subs.vtt" ] &&
      subs_exists=

    jq -er .tooltip!=null "$i" >/dev/null &&
      tooltip_exists=

    {
      printf '<!DOCTYPE html>\n'
      printf -- '<!-- SPDX-License-Identifier: %s -->\n' "$copyright_license_spdx"

      printf -- '<html lang=%s dir=%s>' "$lang" "$lang_d"

      # <head>
      printf '<meta charset=utf-8><meta name=viewport content="width=device-width,initial-scale=1">'

      printf -- '<title>%s</title>' "$(printf_l10n html_title "$title_text")"

      printf -- '<meta name=description content="%s">' "$description_text"
      printf '<meta name=robots content=index,follow>'
      printf -- '<link rel=canonical href=%s hreflang=%s type=text/html>' "$canonical" "$lang"

      if [ "$type" = comic_page ];then
        chapter="$(jq -r .location.chapter "$i")"
        next="$(jq -r .location.next "$i")"
        page="$(jq -r .location.page "$i")"
        prev="$(jq -r .location.previous "$i")"
        series="$(jq -r .location.series "$i")"
        set_var_l10n series_hashtag hashtag "$index/$id/../data.json"
        set_var_l10n series_title title "$index/$id/../data.json"
        test_unset tooltip_exists ||
          set_var_l10n tooltip tooltip "$i"
        volume="$(jq -r .location.volume "$i")"

        # Determine how many directories deep from the series the page is
        up_directories=4

        test_null volume &&
          up_directories="$((up_directories-1))"

        test_null chapter &&
          up_directories="$((up_directories-1))"

        styles="$(
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
          err e 'up_directories is not 2, 3, or 4'
        fi

        printf '<link rel=preload href=%s/%s.css as=style hreflang=zxx type=text/css>' "$styles" "$lang_l"
        printf '<link rel=preload href=%s/comic_page.css as=style hreflang=zxx type=text/css>' "$styles"
        printf '<link rel=stylesheet href=%s/%s.css hreflang=zxx type=text/css>' "$styles" "$lang_l"
        printf '<link rel=stylesheet href=%s/comic_page.css hreflang=zxx type=text/css>' "$styles"

        printf -- '<link rel="external license" href="%s">' "$copyright_license_url_id"

        if   [ "$up_directories" -eq 3 ];then
          chapter="$(jq -r .location.chapter "$i")"
        elif [ "$up_directories" -eq 4 ];then
          volume="$(jq -r .location.volume "$i")"
          chapter="$(jq -r .location.chapter "$i")"
        fi

        parts="$({
          for p in $(jq -r '.parts|to_entries|.[].key' "$index/$id/../data.json");do
            if   [ "$(jq -r --argjson p "$p" -- '.parts[$p]|type' "$index/$id/../data.json")" = number ];then
              printf '%s\n' "$(jq -r --argjson p "$p" -- '.parts[$p]' "$index/$id/../data.json")"
            elif [ "$(jq -r --argjson p "$p" -- '.parts[$p]|type' "$index/$id/../data.json")" = string ];then
              count_from \
                "$(jq -r --argjson p "$p" -- '.parts[$p]' "$index/$id/../data.json"|cut -d- -f1)" \
                "$(jq -r --argjson p "$p" -- '.parts[$p]' "$index/$id/../data.json"|cut -d- -f2)"
            else
              err e 'A part is not number or string'
            fi
          done
        }|sort -nu)"

        exit_if

        container_first="$(printf %s "$parts"|head -n1)"
        container_last="$(printf %s "$parts"|tail -n1)"

        if test_null prev;then
          # This is the first page, so no prefetches are needed.
          :
        elif [ "$container_first" != "$page" ] ||
             [ "$container_first" != "$prev" ];then
          printf -- '<link rel=prefetch href=../../%s/ hreflang=%s type=text/html>' \
                 "$container_first" "$lang"
          printf -- '<link rel="prev prefetch" href=../../%s/ hreflang=%s type=text/html>' \
                 "$prev" "$lang"
        elif [ "$container_first" = "$prev" ];then
          printf -- '<link rel="prev prefetch" href=../../%s/ hreflang=%s type=text/html>' \
                 "$prev" "$lang"
        fi

        if test_null next;then
          # This is the last page, so no prefetches are needed.
          :
        elif [ "$container_last" != "$page" ] ||
             [ "$container_last" != "$next" ];then
          printf -- '<link rel="next prefetch" href=../../%s/ hreflang=%s type=text/html>' \
                 "$next" "$lang"
          printf -- '<link rel=prefetch href=../../%s/ hreflang=%s type=text/html>' \
                 "$container_last" "$lang"
        elif [ "$container_last" = "$next" ];then
          printf -- '<link rel="next prefetch" href=../../%s/ hreflang=%s type=text/html>' \
                 "$next" "$lang"
        fi

        make_og type article
        make_og title "$title_text"
        make_og description "$description_text"
        make_og site_name gabl.ink
        make_og url "$canonical"
        make_og image "${canonical}image.png"
        test_unset video_exists ||
          make_og video "${canonical}video.webm"
        make_og locale "${lang_l}_$lang_r"

        # </head>

        # <body>
        printf '<header>'
        printf '<a href=https://gabl.ink/ id=gabldotink_logo>'
        printf_l10n gabldotink_logo
        printf '</a>'

        printf '<ul id=lang_select>'
        for l in $(printf '%s\n' "$langs"|sort -u);do (
          main_lang="$lang"
          lang="$l"
          parse_lang
          printf -- '<li data-lang_select_flag=%s>' "$lang_r_flag"
          if [ "$l" = "$main_lang" ];then
            printf '<b>'
          else
            printf '<a lang=%s href=../%s/>' "$lang" "$lang_i"
          fi
          printf -- %s "$lang_name_html"
          if [ "$l" = "$main_lang" ];then
            printf '</b>'
          else
            printf '</a>'
          fi
        )
        done
        printf '</ul></header><div id=panels><div id=nav_top><h1 id=nav_top_title>'
        printf_l10n page_title_html "$title_html"
        printf '</h1>'

        test_null container_first ||
          set_var_l10n container_first_title title "$index/$id/../$container_first/data.json"

        test_null prev ||
          set_var_l10n prev_title title "$index/$id/../$prev/data.json"

        test_null next ||
          set_var_l10n next_title title "$index/$id/../$next/data.json"

        test_null container_last ||
          set_var_l10n container_last_title title "$index/$id/../$container_last/data.json"

        make_nav top

        printf '</div><div id=comic_page_'

        # TODO: Edge case: no captions
        if ! test_unset video_exists;then
          printf 'video><video controls poster=image.png preload=auto'
          test_unset tooltip_exists ||
            printf -- ' title="%s"' "$tooltip_text"
          printf '>'
          printf '<source src=video.webm type=video/webm>'
          if ! test_unset captions_exists;then
            printf '<track kind=captions '
            printf -- 'label="%s%s" ' "$lang_name_text" "$(printf_l10n cc)"
            printf -- 'src=cc.vtt srclang=%s>' "$lang"
          fi
          if ! test_unset subs_exists;then
            printf '<track default kind=subtitles '
            printf -- 'label="%s" ' "$lang_name_text"
            printf -- 'src=subs.vtt srclang=%s>' "$lang"
          fi
          printf '<p>'
          printf_l10n video_not_supported "$lang" "$series_title_text" "$title_text"
          printf '</p></video></div>'
        else
          printf 'image><picture'
          test_unset tooltip_exists ||
            printf -- ' title="%s"' "$tooltip_text"
          printf '>'
          printf '<img src=image.png fetchpriority=high alt='
          printf_l10n see_transcript
          printf '></picture></div>'
        fi

        printf '<div id=nav_bottom>'

        make_nav bottom

        printf '<nav id=nav_bottom_list><details id=nav_bottom_list_root><summary>'

        # TODO: Support lower containers (volumes and chapters).

        if [ "$container" = series ];then
          printf_l10n series_title_html "$series_title_html"
        fi

        printf_l10n comma_page "$page"

        printf_l10n page_title_html "$title_html"

        printf '</summary>'

        printf '<ol id=nav_bottom_list_pages>'

        for r in $parts;do
          make_page_list_entry "$index/$id/../$r/data.json"
        done

        unset_var_l10n list_title

        printf '</ol></details></nav></div>'

        printf '<details id=comic_transcript>'

        printf -- '<summary><h2>%s</h2></summary>' "$(printf_l10n transcript_name)"

        printf '<table id=comic_transcript_table>'

        for l in $(jq -r '.transcript|to_entries|.[].key' "$i");do
          l_h="$(jq -r --argjson l "$l" '.transcript[$l].h' "$i")"
          set_var_l10n l_d "transcript[$l].d" "$i"

          l_h_type="$(jq -r .type "$encyclopedia/$l_h/data.json")"
          [ "$l_h_type" = character ] ||
            [ "$l_h_type" = meta_character ] ||
              err e 'l_h_type is not character or meta_character'
          if jq -er .name==null "$encyclopedia/$l_h/data.json" >/dev/null;then
            unset_var_l10n l_h_label
          else
            set_var_l10n l_h_label name.label "$encyclopedia/$l_h/data.json"
            test_null l_h_label &&
              set_var_l10n l_h_label name.given "$encyclopedia/$l_h/data.json"
          fi

          exit_if

          printf '<tr>'
          printf '<th scope=row>%s' "$l_h_label_html"
          printf '<td>'
          case "$l_d_html" in
            '<'*)
              printf -- %s "$l_d_html" ;;
            *)
              printf -- '<p>%s' "$l_d_html"
          esac
        done

        printf '</table></details><hr>'

        printf '<h2>%s</h2>' "$(printf_l10n log)"

        for k in $(jq -r '.log|keys[]' "$i");do
          log_date_d="$(jq -r --argjson k "$k" '.log[$k].date.d' "$i")"
          log_date_m="$(jq -r --argjson k "$k" '.log[$k].date.m' "$i")"
          log_date_y="$(jq -r --argjson k "$k" '.log[$k].date.y' "$i")"

          printf '<article id=log_'

          printf -- %s-%s-%s "$(zero_pad 4 log_date_y)" "$(zero_pad 2 log_date_m)" "$(zero_pad 2 log_date_d)"

          printf '><details>'
          printf -- '<summary><h3>%s</h3></summary>' "$(say_date log_date)"

          for p in $(jq -r --argjson k "$k" '.log[$k].content|keys[]' "$i");do
            set_var_l10n log_content_p "log[$k].content[$p]" "$i"
            case "$log_content_p_html" in
              '<'*)
                printf -- %s "$log_content_p_html" ;;
              *)
                printf -- '<p>%s' "$log_content_p_html"
            esac
          done

          printf '</details></article>'
        done

        printf '<hr>'

        printf '<p id=canonical_url>'
        printf '%s<a href=%s hreflang=%s type=text/html>%s</a>' "$(printf_l10n canonical_url)" "$canonical" "$lang" "$canonical"


        printf '<details id=share_links>'
        printf '<summary>%s</summary>' "$(printf_l10n share_this_page)"
        printf '<ul>'

        make_share_link_url="$(printf %s "$canonical"|jq -Rr @uri)"

        make_share_link email \
                       "$(printf_l10n gabldotink_series_page '' "$series_title_text" "$title_text")" \
                       "$(
                          printf_l10n from_gabldotink
                          printf %s "$canonical"
                        )"

        make_share_link sms '' \
                       "$(
                          printf_l10n gabldotink_series_page '' "$series_title_text" "$title_text"
                          printf ' %s' "$canonical"
                        )"

        make_share_link x '' \
                       "$(printf_l10n gabldotink_series_page ' @gabldotink' "$series_title_text" "$title_text")" \
                       "gabldotink,$series_hashtag_id"

        make_share_link reddit \
                       "$(printf_l10n gabldotink_series_page '' "$series_title_text" "$title_text")"

        make_share_link facebook

        make_share_link telegram '' \
                       "$(
                          printf_l10n gabldotink_series_page '' "$series_title_text" "$title_text"
                          printf -- ' #gabldotink #%s' "$series_hashtag_id"
                        )"

        make_share_link bluesky '' \
                       "$(
                          printf_l10n gabldotink_series_page ' @gabl.ink' "$series_title_text" "$title_text"
                          printf -- ' %s #gabldotink #%s' "$canonical" "$series_hashtag_id"
                        )"

        make_share_link whatsapp '' \
                       "$(
                          printf_l10n gabldotink_series_page '' "$series_title_text" "$title_text"
                          printf ' %s' "$canonical"
                        )"

        make_share_link mastodon '' \
                       "$(
                          printf_l10n gabldotink_series_page ' @gabldotink@mstdn.party' "$series_title_text" "$title_text"
                          printf -- ' #gabldotink #%s' "$series_hashtag_id"
                        )"

        make_share_link threads '' \
                       "$(
                          printf_l10n gabldotink_series_page '' "$series_title_text" "$title_text"
                          printf -- ' #gabldotink #%s' "$series_hashtag_id"
                        )"

        make_share_link truth_social '' \
                       "$(
                          printf_l10n gabldotink_series_page '' "$series_title_text" "$title_text"
                          printf -- ' #gabldotink #%s' "$series_hashtag_id"
                        )"

        make_share_link gab '' \
                       "$(
                          printf_l10n gabldotink_series_page '' "$series_title_text" "$title_text"
                          printf -- ' #gabldotink #%s' "$series_hashtag_id"
                        )"

        make_share_link vk \
                       "$(
                          printf_l10n gabldotink_series_page '' "$series_title_text" "$title_text"
                        )" \
                       "$(
                          printf_l10n from_gabldotink
                          printf -- '%s #gabldotink #%s' "$canonical" "$series_hashtag_id"
                        )"

        printf '</ul></details>'

        printf '<details id=validate_links>'
        printf -- '<summary>%s</summary>' "$(printf_l10n validate_this_page)"
        printf '<ul>'

        make_validate_link vnu
        make_validate_link w3c

        printf '</ul></details>'
      fi

      printf '<footer><p><span class=nw>'
      printf -- '<abbr title=%s>©</abbr>\302\240' "$(printf_l10n copyright)"
      printf -- %s "$copyright_year_first"
      ! test_null copyright_year_last &&
        printf -- –%s "$copyright_year_last"
      printf '</span> <span translate=no>gabl.ink</span>'

      printf -- '<p>%s<a rel="external license" href="%s">' "$(printf_l10n license)" "$copyright_license_url_id"
      printf -- '<cite>%s</cite>' "$copyright_license_title_html"
      ! test_null copyright_license_abbr &&
        printf -- ' (<cite><abbr>%s</abbr></cite>)' "$copyright_license_abbr_html"
      printf '</a>'

      if ! test_null disclaimer;then
        set_var_l10n disclaimer "\"$disclaimer\"" "$dict/disclaimer.json"
        printf -- '<p>%s%s' "$(printf_l10n disclaimer)" "$disclaimer_html"
      fi

      printf '</footer></div>\n'
      # </body></html>

      exit_if
    } > "$tmpfile"

    # Last chance to error out before permanently writing the file
    exit_if

    flush_from_tmp "$tmpfile" "$index/$id/$lang_i/index.html"

    err i 'lang done'
    ) &
  done
  wait
  unset lang
  err i 'item done'
  ) &
done
wait

rm -f "$scripts/build.lock"

err i 'section done: items'

trap - INT EXIT

[ "$warned" = true ] &&
  [ "$config_exit_nonzero_with_warnings" = true ] &&
    exit 2

exit_if

exit 0
