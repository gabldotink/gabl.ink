#!/bin/sh
# SPDX-License-Identifier: CC-BY-4.0

export POSIXLY_CORRECT

if ! command -v jq >/dev/null 2>&1;then
  printf '[error] jq must be installed in your PATH to run this script.\n'
  exit 1
fi

script="$0"

index="$(dirname -- "$script")/../.."

dict="$index/en/dictionary"

#items="$(find "$index" -type f -name data.json)"
items="$index/en/jrco_beta/01/data.json"

for i in $items;do
  type="$(jq -r -- .type "$i")"

  if [ "$type" = comic_series ];then
    continue
  fi

  # Do not try to use named pipes (FIFOs) to run jq in parallel. It doesn’t help much, and is actually slower on Cygwin.
  copyright_license="$(jq -r -- .copyright.license[0] "$i")"
  # Literal quotation marks should be used when inserting variables into jq (hyphens can cause issues).
  copyright_license_url="$(jq -r -- ".\"$copyright_license\".url" "$dict/copyright_license.json")"
  copyright_license_spdx="$(jq -r -- ".\"$copyright_license\".spdx" "$dict/copyright_license.json")"
  description_text="$(jq -r -- .description.text "$i")"
  id="$(jq -r -- .id "$i")"
  language="$(jq -r -- .language "$i")"
  language_bcp_47_full="$(jq -r -- ".\"$language\".bcp_47.full" "$dict/language.json")"
  language_dir="$(jq -r -- ".\"$language\".dir" "$dict/language.json")"
  title_text="$(jq -r -- .title.text "$i")"

  canonical="https://gabl.ink/index/$id/"

  printf '<!DOCTYPE html>'

  printf '<html lang="%s" dir="%s" xmlns="http://www.w3.org/1999/xhtml" xml:lang="%s">\n' "$language_bcp_47_full" "$language_dir" "$language_bcp_47_full"

  printf '<!-- SPDX-License-Identifier: %s -->\n' "$copyright_license_spdx"

  printf '<head>'
  printf '<meta charset="utf-8">'
  printf '<meta name="viewport" content="width=device-width,initial-scale=1"/>'

  printf '<title>gabl.ink – %s</title>' "$title_text"

  printf '<meta name="description" content="%s"/>' "$description_text"
  printf '<meta name="robots" content="index,follow"/>'
  printf '<link rel="canonical" href="%s" hreflang="en-US" type="text/html"/>' "$canonical"

  if [ "$type" = comic_page ];then
    copyright_license_abbr="$(jq -r -- ".\"$copyright_license\".abbr" "$dict/copyright_license.json")"
    copyright_license_title="$(jq -r -- ".\"$copyright_license\".title" "$dict/copyright_license.json")"
    copyright_year_first="$(jq -r -- .copyright.year.first "$i")"
    copyright_year_last="$(jq -r -- .copyright.year.last "$i")"
    disclaimer="$(jq -r -- .disclaimer[0] "$i")"
    first_published_d="$(jq -r -- .first_published.d "$i")"
    if [ "${#first_published_d}" -eq 1 ];then
      first_published_d_pad=0
    fi
    first_published_m="$(jq -r -- .first_published.m "$i")"
    if [ "${#first_published_m}" -eq 1 ];then
      first_published_m_pad=0
    fi
    first_published_y="$(jq -r -- .first_published.y "$i")"
    if   [ "${#first_published_y}" -eq 3 ];then
      first_published_y_pad=0
    elif [ "${#first_published_y}" -eq 2 ];then
      first_published_y_pad=00
    elif [ "${#first_published_y}" -eq 1 ];then
      first_published_y_pad=000
    fi
    language_ogp_full="$(jq -r -- ".\"$language\".ogp.full" "$dict/language.json")"
    location_chapter="$(jq -r -- .location.chapter "$i")"
    location_next_string="$(jq -r -- .location.next.string "$i")"
    location_page_integer="$(jq -r -- .location.page.integer "$i")"
    location_page_string="$(jq -r -- .location.page.string "$i")"
    location_previous_string="$(jq -r -- .location.previous.string "$i")"
    location_series="$(jq -r -- .location.series "$i")"
    location_series_hashtag="$(jq -r -- .hashtag "$index/$id/../data.json")"
    location_series_title_disambiguation_html="$(jq -r -- .title.disambiguation.html "$index/$id/../data.json")"
    location_series_title_html="$(jq -r -- .title.html "$index/$id/../data.json")"
    location_series_title_text="$(jq -r -- .title.text "$index/$id/../data.json")"
    location_volume="$(jq -r -- .location.volume "$i")"
    title_html="$(jq -r -- .title.html "$i")"
    title_quotes_nested_html="$(jq -r -- .title.quotes_nested.html "$i")"
    title_quotes_nested_text="$(jq -r -- .title.quotes_nested.text "$i")"

    if [ "$title_quotes_nested_text" != null ];then
      title_quotes_nested_exists=true
    fi

    # For future reference: Each video should have a WebM (VP9/Opus) and MP4 (H.264/AAC) version. WebM should be preferred, due to being free (libre), and MP4 should be provided as a fallback for compatibility. In case of a video, image.png act as a thumbnail.
    if [ -f "$index/$id/video.webm" ];then
      video_exists=true
    fi

    # Determine how many directories deep from the series the page is
    up_directories=4

    if [ "$location_volume" = null ];then
      up_directories="$((up_directories-1))"
    fi

    if [ "$location_chapter" = null ];then
      up_directories="$((up_directories-1))"
    fi

    up_directories_path="$(
      # ShellCheck warns “n” is unused, but that’s intentional
      # shellcheck disable=SC2034
      for n in $(seq 1 "$up_directories");do
        printf ../
      done
    )"

    if   [ "$up_directories" -eq 2 ];then
      container=series
    elif [ "$up_directories" -eq 3 ];then
      container=chapter
    elif [ "$up_directories" -eq 4 ];then
      container=volume
    fi

    printf '<link rel="preload" href="%sstyle/global.css" as="style" hreflang="en-US" type="text/css"/>' "$up_directories_path"
    printf '<link rel="preload" href="%sstyle/comic_page_%s.css" as="style" hreflang="en-US" type="text/css"/>' "$up_directories_path" "$location_series"
    printf '<link rel="stylesheet" href="%sstyle/global.css" hreflang="en-US" type="text/css"/>' "$up_directories_path"
    printf '<link rel="stylesheet" href="%sstyle/comic_page_%s.css" hreflang="en-US" type="text/css"/>' "$up_directories_path" "$location_series"

    printf '<link rel="license" href="%s" hreflang="en" type="text/html"/>' "$copyright_license_url"

    if [ "$up_directories" -eq 4 ];then
      location_volume="$(jq -r -- .location.volume "$i")"
      location_chapter="$(jq -r -- .location.chapter "$i")"
      container_pages_first_string="$(jq -r -- .pages.first.string "$index/en/$location_series/$location_volume/$location_chapter/data.json")"
      container_pages_last_string="$(jq -r -- .pages.last.string "$index/en/$location_series/$location_volume/$location_chapter/data.json")"
    elif [ "$up_directories" -eq 3 ];then
      chapter="$(jq -r -- .location.chapter "$i")"
      container_pages_first_string="$(jq -r -- .pages.first.string "$index/en/$location_series/$chapter/data.json")"
      container_pages_last_string="$(jq -r -- .pages.last.string "$index/en/$location_series/$chapter/data.json")"
    elif [ "$up_directories" -eq 2 ];then
      container_pages_first_string="$(jq -r -- .pages.first.string "$index/en/$location_series/data.json")"
      container_pages_last_string="$(jq -r -- .pages.last.string "$index/en/$location_series/data.json")"
    fi

    if   [ "$location_previous_string" = null ];then
      # This is the first page, so no prefetches are needed.
      true
    elif [ "$container_pages_first_string" != "$location_page_string" ] ||
         [ "$container_pages_first_string" != "$location_previous_string" ];then
      printf '<link rel="prefetch" href="../%s/" hreflang="%s" type="text/html"/>' "$container_pages_first_string" "$language_bcp_47_full"
      printf '<link rel="prev prefetch" href="../%s/" hreflang="%s" type="text/html"/>' "$location_previous_string" "$language_bcp_47_full"
    elif [ "$container_pages_first_string"  = "$location_previous_string" ];then
      printf '<link rel="prev prefetch" href="../%s/" hreflang="%s" type="text/html"/>' "$location_previous_string" "$language_bcp_47_full"
    fi

    if   [ "$location_next_string" = null ];then
      # This is the last page, so no prefetches are needed.
      true
    elif [ "$container_pages_last_string" != "$location_page_string" ] ||
         [ "$container_pages_last_string" != "$location_next_string" ];then
      printf '<link rel="next prefetch" href="../%s/" hreflang="%s" type="text/html"/>' "$location_next_string" "$language_bcp_47_full"
      printf '<link rel="prefetch" href="../%s/" hreflang="%s" type="text/html"/>' "$container_pages_last_string" "$language_bcp_47_full"
    elif [ "$container_pages_last_string"  = "$location_next_string" ];then
      printf '<link rel="next prefetch" href="../%s/" hreflang="%s" type="text/html"/>' "$location_next_string" "$language_bcp_47_full"
    fi

    make_og() {
      make_og_property="$1"
      make_og_content="$2"

      printf '<meta property="og:%s" content="%s"/>' "$make_og_property" "$make_og_content"
    }

    make_og type article
    make_og title "$title_text"
    make_og description "$description_text"
    make_og site_name gabl.ink
    make_og url "$canonical"
    make_og image "$canonical"image.png
    if [ "$video_exists" = true ];then
      make_og video "$canonical"video.webm
      make_og video "$canonical"video.mp4
    fi
    make_og locale "$language_ogp_full"

    printf '</head>'

    printf '<body>'
    printf '<header>'
    printf '<a href="https://gabl.ink/">'
    printf '<picture id="gabldotink_logo">'
    printf '<img src="./logo.svg" alt="gabl.ink logo"/>'
    printf '</picture></a></header>'
    printf '<main>'
    printf '<div id="nav_top">'
    printf '<h1 id="nav_top_title">'
    printf '“<cite>'

    if [ "$title_quotes_nested_exists" = true ];then
      printf '%s' "$title_quotes_nested_html"
    else
      printf '%s' "$title_html"
    fi

    printf '</cite>”</h1>'

    if [ "$container_pages_first_string" != null ];then
      container_pages_first_string_title_text="$(jq -r -- .title.text "$index/$id/../$container_pages_first_string/data.json")"
    fi

    if [ "$location_previous_string" != null ];then
      location_previous_string_title_text="$(jq -r -- .title.text "$index/$id/../$location_previous_string/data.json")"
    fi

    if [ "$location_next_string" != null ];then
      location_next_title_text="$(jq -r -- .title.text "$index/$id/../$location_next_string/data.json")"
    fi

    if [ "$container_pages_last_string" != null ];then
      container_pages_last_string_title_text="$(jq -r -- .title.text "$index/$id/../$container_pages_last_string/data.json")"
    fi

    # TODO: Reduce duplicate code.
    # TODO: Handle multiple chapters.
    # TODO: Handle quotation marks in other page titles.

    make_nav_buttons() {
      make_nav_buttons_l="$1"

      printf '<div id="nav_%s_buttons">' "$make_nav_buttons_l"

      printf '<div class="nav_button" id="nav_%s_buttons_first" ' "$make_nav_buttons_l"

      if [ "$container_pages_first_string" = null ];then
        printf 'title="First in %s (This is the first page!)">' "$container"
        printf '<picture class="nav_buttons_off">'
      else
        printf 'title="First in %s (“%s”)">' "$container" "$container_pages_first_string_title_text"
        printf '<a href="../%s/" hreflang="en-US" type="text/html">' "$container_pages_first_string"
        printf '<picture>'
      fi

      printf '<img class="nav_buttons" src="./first.png" alt="first"/>'
      printf '</picture>'

      if [ "$container_pages_first_string" != null ];then
        printf '</a>'
      fi

      printf '</div>'

      printf '<div class="nav_button" id="nav_%s_buttons_previous" ' "$make_nav_buttons_l"

      if [ "$location_previous_string" = null ];then
        printf 'title="Previous (This is the first page!)">'
        printf '<picture class="nav_buttons_off">'
      else
        printf 'title="Previous (“%s”)">' "$location_previous_string_title_text"
        printf '<a href="../%s/" rel="prev" hreflang="en-US" type="text/html">' "$location_previous_string"
        printf '<picture>'
      fi

      printf '<img class="nav_buttons" src="./previous.png" alt="previous"/>'
      printf '</picture>'

      if [ "$location_previous_string" != null ];then
        printf '</a>'
      fi

      printf '</div>'

      printf '<div class="nav_button" id="nav_%s_buttons_next" ' "$make_nav_buttons_l"

      if [ "$location_next_string" = null ];then
        printf 'title="Next (This is the last page!)">'
        printf '<picture class="nav_buttons_off">'
      else
        printf 'title="Next (“%s”)">' "$location_next_title_text"
        printf '<a href="../%s/" rel="next" hreflang="en-US" type="text/html">' "$location_next_string"
        printf '<picture>'
      fi

      printf '<img class="nav_buttons" src="./next.png" alt="next"/>'
      printf '</picture>'

      if [ "$location_next_string" != null ];then
        printf '</a>'
      fi

      printf '</div>'

      printf '<div class="nav_button" id="nav_%s_buttons_last" ' "$make_nav_buttons_l"

      if [ "$container_pages_last_string" = null ];then
        printf 'title="Last in %s (This is the last page!)">' "$container"
        printf '<picture class="nav_buttons_off">'
      else
        printf 'title="Last in %s (“%s”)">' "$container" "$container_pages_last_string_title_text"
        printf '<a href="../%s/" hreflang="en-US" type="text/html">' "$container_pages_last_string"
        printf '<picture>'
      fi

      printf '<img class="nav_buttons" src="./last.png" alt="last"/>'
      printf '</picture>'

      if [ "$container_pages_last_string" != null ];then
        printf '</a>'
      fi

      printf '</div></div>'
    }

    make_nav_buttons top

    printf '</div>'

    printf '<div id="comic_page_'

    # TODO: Edge case: one format exists, other doesn’t
    # TODO: Edge case: no captions
    # TODO: Browsers fix “id” for filesystems, but we should get better filenames, in addition to easy download links
    if [ "$video_exists" = true ];then
      printf 'video"><video controls="" poster="./image.png" preload="metadata">'
      printf '<source src="./video.webm" type="video/webm"/>'
      printf '<source src="./video.mp4" type="video/mp4"/>'
      printf '<track default="" kind="captions" '
      printf 'label="English (United States) (CC)" '
      printf 'src="./track_en-us_cc.vtt" srclang="en-US"/>'
      # TODO: Figure out why ShellCheck warns about the apostrophe without double quotes
      printf '<p>It looks like your web browser doesn'"’"'t support the <code>video</code> element. You can download the video as a <a href="./video.webm" hreflang="en-US" type="video/webm" download="%s.webm">WebM</a> or <a href="./video.mp4" hreflang="en-US" type="video/mp4" download="%s.mp4">MP4</a> file to watch with your preferred video player. You can also view the transcript for the video at “Comic transcript” below.</p>' "$id" "$id"
      printf '</video></div>'
    else
      printf 'image"><picture>'
      printf '<img src="./image.png" alt="See “Comic transcript” below"/>'
      printf '</picture></div>'
    fi

    printf '<div id="nav_bottom">'

    make_nav_buttons bottom

    printf '<div id="nav_bottom_list">'

    printf '<details id="nav_bottom_list_root">'

    printf '<summary>'

    printf '<i><cite>'

    # TODO: Support higher containers (volumes and chapters).

    if [ "$container" = series ];then
      printf '%s' "$location_series_title_html"
      printf '</cite></i>'

      if [ "$location_series_title_disambiguation_html" != null ];then
        printf ' %s' "$location_series_title_disambiguation_html"
      fi
    fi

    printf ', page %s ' "$location_page_integer"

    printf '“<cite>'

    if [ "$title_quotes_nested_exists" = true ];then
      printf '%s' "$title_quotes_nested_html"
    else
      printf '%s' "$title_html"
    fi
    
    printf '</cite>”'

    printf '</summary>'

    printf '<ol id="nav_bottom_list_pages">'

    find "$index/$id/.." -type f -path "$index/$id/../*/data.json" -exec sh -c '
      d="$1"
      p="$2"
      s="$(jq -r -- .location.page.string "$d")"

      printf "<li>“"

      if [ "$s" = "$p" ];then
        printf "<b><cite>"
        if [ "$(jq -r .title.quotes_nested.html "$d")" != null ];then
          printf "%s" "$(jq -r -- .title.quotes_nested.html "$d")"
        else
          printf "%s" "$(jq -r -- .title.html "$d")"
        fi
        printf "</cite></b>”</li>"
      else
        printf "<a href=\"../"
        printf "%s" "$s"
        printf "/\" hreflang=\"en-US\" type=\"text/html\"><cite>"
        if [ "$(jq -r .title.quotes_nested.html "$d")" != null ];then
          printf "%s" "$(jq -r -- .title.quotes_nested.html "$d")"
        else
          printf "%s" "$(jq -r -- .title.html "$d")"
        fi
        printf "</cite></a>”</li>"
      fi
    ' shell '{}' "$location_page_string" ';'

    printf '</ol>'

    printf '</details>'
    printf '</div></div>'

    printf '<details id="comic_transcript" open="">'

    printf '<summary>Comic transcript</summary>'

    printf '<table id="comic_transcript_table">'

    printf '<thead>'
    printf '<tr>'
    printf '<th scope="col">Speaker</th>'
    printf '<th scope="col">Text</th>'
    printf '</tr>'
    printf '</thead>'

    for l in $(jq -r -- '.transcript.lines|to_entries|.[].key' "$i");do
      h="$(jq -r -- ".transcript.lines[$l].h" "$i")"
      d="$(jq -r -- ".transcript.lines[$l].d" "$i")"
      printf '<tr>'
      printf '<th scope="row">%s</th>' "$h"
      printf '<td><p>%s</p></td>' "$d"
    done

    printf '</table></details>'

    printf '<p id="first_published">First published <time class="nw" datetime="'

    printf '%s-%s-%s' "$first_published_y_pad""$first_published_y" "$first_published_m_pad""$first_published_m" "$first_published_d_pad""$first_published_d"

    printf '">'

    printf '%s ' "$(jq -r -- ".months[$((first_published_m-1))]" "$dict/month_gregorian.json")"
    printf '%s, ' "$first_published_d"
    if [ "${#first_published_y}" -lt 4 ];then
      printf '<abbr title="anno Domini">AD</abbr> %s' "$first_published_y"
    elif [ "$first_published_y" -eq 0 ];then
      printf '1 <abbr title="before Christ">BC</abbr>'
    else
      printf '%s' "$first_published_y"
    fi

    printf '</time>'
    printf '</p>'

    for p in $(jq -r -- '.post|to_entries|.[].key' "$i");do
      post_content="$(jq -r -- ".post[$p].content.html" "$i")"
      post_date_d="$(jq -r -- ".post[$p].date.d" "$i")"
      if [ "${#post_date_d}" -eq 1 ];then
        post_date_d_pad=0
      fi
      post_date_m="$(jq -r -- ".post[$p].date.m" "$i")"
      if [ "${#post_date_m}" -eq 1 ];then
        post_date_m_pad=0
      fi
      post_date_y="$(jq -r -- ".post[$p].date.y" "$i")"
      if   [ "${#post_date_y}" -eq 3 ];then
        post_date_y_pad=0
      elif [ "${#post_date_y}" -eq 2 ];then
        post_date_y_pad=00
      elif [ "${#post_date_y}" -eq 1 ];then
        post_date_y_pad=000
      fi
      
      printf '<article id="post_'

      printf '%s-%s-%s' "$post_date_y_pad""$post_date_y" "$post_date_m_pad""$post_date_m" "$post_date_d_pad""$post_date_d"

      printf '">'

      printf '<h2 class="nw">'
      printf '<time datetime="%s-%s-%s">' "$post_date_y_pad""$post_date_y" "$post_date_m_pad""$post_date_m" "$post_date_d_pad""$post_date_d"

      printf '%s ' "$(jq -r -- ".months[$((post_date_m-1))]" "$dict/month_gregorian.json")"
      printf '%s, ' "$post_date_d"
      if [ "${#post_date_y}" -lt 4 ];then
        printf '<abbr title="anno Domini">AD</abbr> %s' "$post_date_y"
      elif [ "$post_date_y" -eq 0 ];then
        printf '1 <abbr title="before Christ">BC</abbr>'
      else
        printf '%s' "$post_date_y"
      fi

      printf '</time></h2>'

      printf '%s' "$post_content"

      printf '</article>'
    done

    printf '</main>'

    printf '<details id="share_links">'
    printf '<summary>Share this page</summary>'
    printf '<ul>'

    # usage: make_share_link <HTML id> <platform name> <base share URL> <parameter for text> <parameter for URL> <parameter for hashtag(s)> <text> <URL> <hashtag(s)>
    make_share_link() {
      make_share_link_id="$1"
      make_share_link_platform="$2"
      make_share_link_base="$3"
      make_share_link_text_param="$4"
      make_share_link_url_param="$5"
      make_share_link_hashtag_param="$6"
      make_share_link_text="$(printf '%s' "$7"|jq -Rr -- @uri)"
      make_share_link_url="$(printf '%s' "$8"|jq -Rr -- @uri)"
      make_share_link_hashtag="$(printf '%s' "$9"|jq -Rr -- @uri)"

      printf '<li id="share_links_%s">' "$make_share_link_id"
      printf '<a rel="external" href="%s' "$make_share_link_base"

      if [ "$make_share_link_id" = reddit ];then
        make_share_link_start_param='&amp;'
      else
        # ShellCheck warns this “?” is literal, but that’s intentional
        # shellcheck disable=SC2125
        make_share_link_start_param=?
      fi

      if [ -n "$make_share_link_text_param" ];then
        printf '%s%s=' "$make_share_link_start_param" "$make_share_link_text_param"
        printf '%s' "$make_share_link_text"
        if [ "$make_share_link_start_param" = '?' ];then
          make_share_link_start_param='&amp;'
        fi
      fi

      if [ -n "$make_share_link_url_param" ];then
        printf '%s%s=' "$make_share_link_start_param" "$make_share_link_url_param"
        printf '%s' "$make_share_link_url"
        if [ "$make_share_link_start_param" = '?' ];then
          make_share_link_start_param='&amp;'
        fi
      fi

      if [ -n "$make_share_link_hashtag_param" ];then
        printf '%s%s=' "$make_share_link_start_param" "$make_share_link_hashtag_param"
        printf '%s' "$make_share_link_hashtag"
      fi

      printf '">'
      printf 'Share with %s' "$make_share_link_platform"
      printf '</a></li>'
    }

    make_share_link x X https://x.com/intent/tweet text url hashtags \
                   "$(
                      printf 'gabl.ink @gabldotink: '
                      printf '“%s”: “' "$location_series_title_text"
                      if [ "$title_quotes_nested_exists" = true ];then
                        printf '%s' "$title_quotes_nested_text"
                      else
                        printf '%s' "$title_text"
                      fi
                      printf '”'
                    )" \
                   "$canonical" \
                   "gabldotink,$location_series_hashtag"
    
    make_share_link reddit Reddit 'https://www.reddit.com/submit?type=LINK' title url '' \
                   "$(
                      printf 'gabl.ink: '
                      printf '“%s”: “' "$location_series_title_text"
                      if [ "$title_quotes_nested_exists" = true ];then
                        printf '%s' "$title_quotes_nested_text"
                      else
                        printf '%s' "$title_text"
                      fi
                      printf '”'
                    )" \
                   "$canonical"
    
    make_share_link facebook Facebook https://www.facebook.com/sharer/sharer.php '' u '' '' \
                   "$canonical"
    
    make_share_link telegram Telegram https://t.me/share text url '' \
                   "$(
                      printf 'gabl.ink: '
                      printf '“%s”: “' "$location_series_title_text"
                      if [ "$title_quotes_nested_exists" = true ];then
                        printf '%s' "$title_quotes_nested_text"
                      else
                        printf '%s' "$title_text"
                      fi
                      printf '” '
                      printf '#gabldotink #%s' "$location_series_hashtag"
                    )" \
                   "$canonical"
    
    make_share_link bluesky Bluesky https://bsky.app/intent/compose text '' '' \
                   "$(
                      printf 'gabl.ink @gabl.ink: '
                      printf '“%s”: “' "$location_series_title_text"
                      if [ "$title_quotes_nested_exists" = true ];then
                        printf '%s' "$title_quotes_nested_text"
                      else
                        printf '%s' "$title_text"
                      fi
                      printf '” '
                      printf '%s ' "$canonical"
                      printf '#gabldotink #%s' "$location_series_hashtag"
                    )"
    
    make_share_link whatsapp WhatsApp https://wa.me/ text '' '' \
                   "$(
                      printf 'gabl.ink: '
                      printf '“%s”: “' "$location_series_title_text"
                      if [ "$title_quotes_nested_exists" = true ];then
                        printf '%s' "$title_quotes_nested_text"
                      else
                        printf '%s' "$title_text"
                      fi
                      printf '” %s' "$canonical"
                    )"
    
    make_share_link mastodon Mastodon https://mastodonshare.com/ text url '' \
                   "$(
                      printf 'gabl.ink @gabldotink@mstdn.party: '
                      printf '“%s”: “' "$location_series_title_text"
                      if [ "$title_quotes_nested_exists" = true ];then
                        printf '%s' "$title_quotes_nested_text"
                      else
                        printf '%s' "$title_text"
                      fi
                      printf '” '
                      printf '#gabldotink #%s' "$location_series_hashtag"
                    )" \
                   "$canonical"
    
    make_share_link threads Threads https://www.threads.com/intent/post text url '' \
                   "$(
                      printf 'gabl.ink: '
                      printf '“%s”: “' "$location_series_title_text"
                      if [ "$title_quotes_nested_exists" = true ];then
                        printf '%s' "$title_quotes_nested_text"
                      else
                        printf '%s' "$title_text"
                      fi
                      printf '” '
                      printf '#gabldotink #%s' "$location_series_hashtag"
                    )" \
                   "$canonical"

    make_share_link truthsocial 'Truth Social' https://truthsocial.com/share text url '' \
                   "$(
                      printf 'gabl.ink: '
                      printf '“%s”: “' "$location_series_title_text"
                      if [ "$title_quotes_nested_exists" = true ];then
                        printf '%s' "$title_quotes_nested_text"
                      else
                        printf '%s' "$title_text"
                      fi
                      printf '” '
                      printf '#gabldotink #%s' "$location_series_hashtag"
                    )" \
                   "$canonical"

    make_share_link gab Gab https://gab.com/compose text url '' \
                   "$(
                      printf 'gabl.ink: '
                      printf '“%s”: “' "$location_series_title_text"
                      if [ "$title_quotes_nested_exists" = true ];then
                        printf '%s' "$title_quotes_nested_text"
                      else
                        printf '%s' "$title_text"
                      fi
                      printf '” '
                      printf '#gabldotink #%s' "$location_series_hashtag"
                    )" \
                   "$canonical"

    printf '</ul></details>'

    printf '<footer>'
    printf '<span class="nw">'
    printf '<abbr title="Copyright">©</abbr> '
    printf '<time>%s</time>' "$copyright_year_first"
    if [ "$copyright_year_last" != null ];then
      printf '–<time>%s</time>' "$copyright_year_last"
    fi
    printf '</span> '
    printf '<span translate="no">gabl.ink</span><br/>'

    printf 'License: <a rel="external license" href="%s" ' "$copyright_license_url"
    printf 'hreflang="en" type="text/html">'
    printf '%s' "$copyright_license_title"
    if [ "$copyright_license_abbr" != null ];then
      printf ' (<abbr>%s</abbr>)' "$copyright_license_abbr"
    fi
    printf '</a>'

    if [ "$disclaimer" != null ];then
      disclaimer_html="$(jq -r -- ".\"$disclaimer\".html" "$dict/disclaimer.json")"
      printf '<br/>Disclaimer: %s' "$disclaimer_html"
    fi

    printf '</footer>'
  fi

  printf '</body></html>'
done
