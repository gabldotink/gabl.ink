#!/bin/sh
# SPDX-License-Identifier: CC0-1.0

export POSIXLY_CORRECT

script="$0"

scripts="$(dirname -- "${script}")"
cms="${scripts}/.."
dict="${cms}/dictionaries"
index="${cms}/../index"

export TEXTDOMAIN TEXTDOMAINDIR
TEXTDOMAIN=build
TEXTDOMAINDIR="${scripts}/l10n"

error() {
  error_msg="$1"
  error_exit_code="$2"
  gettext 'error: '
  [ -n "${id}" ] &&
    printf '%s: ' "${id}"
  printf '%s\n' "${error_msg}"
  if [ -n "${error_exit_code}" ];then
    exit "${error_exit_code}"
  else
    exit 1
  fi
}

warning() {
  warning_msg="$1"
  warning_exit_code="$2"
  gettext 'warning: '
  [ -n "${id}" ] &&
    printf '%s: ' "${id}"
  printf '%s\n' "${warning_msg}"
  warning_warned=true
  [ "${config_exit_on_warning}" = true ] &&
    if [ -n "${warning_exit_code}" ];then
      exit "${warning_exit_code}"
    else
      exit 1
    fi
}

load_lib() {
  load_lib_file="$1.sh"
  # shellcheck source=/dev/null
  . "${scripts}/lib/${load_lib_file}"
  # || error '%s/lib/%s could not be loaded' "$scripts" "$load_lib_file"
  # The shell gives its own error
}

command -v jq >/dev/null 2>&1 ||
  error 'jq is not installed in PATH'

load_lib make_og
load_lib make_nav_buttons
load_lib make_share_link
load_lib make_validate_link

# We must use an if statement here to use a ShellCheck directive
if [ -f "${scripts}/config/build.sh" ];then
  # shellcheck source=./config/build.sh
  . "${scripts}/config/build.sh"
fi

if [ "${config_lang_default}" != en ];then
  lang_default="${config_lang_default}"
else
  lang_default=en
fi

#items="$(find "${index}" -type f -name data.json)"
items="${index}/en/jrco_beta/01/data.json"

for i in ${items};do
  type="$(jq -r -- .type "${i}")"
  
  [ "${type}" = comic_series ] &&
    continue

  lang="$(jq -r -- .language "${i}")"
  
  copyright_license="$(jq -r -- .copyright.license[0] "${i}")"
  # Literal quotation marks should be used when inserting variables into jq (hyphens can cause issues).
  copyright_license_abbr="$(jq -r -- ".\"${copyright_license}\".abbr.\"${lang}\"" "${dict}/copyright_license.json")"
  copyright_license_abbr_default="$(jq -r -- ".\"${copyright_license}\".abbr.\"${lang_default}\"" "${dict}/copyright_license.json")"
  copyright_license_abbr_mul="$(jq -r -- ".\"${copyright_license}\".abbr.mul" "${dict}/copyright_license.json")"
  copyright_license_url="$(jq -r -- ".\"${copyright_license}\".url.\"${lang}\"" "${dict}/copyright_license.json")"
  copyright_license_url_default="$(jq -r -- ".\"${copyright_license}\".url.\"${lang_default}\"" "${dict}/copyright_license.json")"
  copyright_license_url_mul="$(jq -r -- ".\"${copyright_license}\".url.mul" "${dict}/copyright_license.json")"
  copyright_license_spdx="$(jq -r -- ".\"${copyright_license}\".spdx" "${dict}/copyright_license.json")"
  copyright_license_title="$(jq -r -- ".\"${copyright_license}\".title.\"${lang}\"" "${dict}/copyright_license.json")"
  copyright_license_title_default="$(jq -r -- ".\"${copyright_license}\".title.\"${lang_default}\"" "${dict}/copyright_license.json")"
  copyright_license_title_mul="$(jq -r -- ".\"${copyright_license}\".title.mul" "${dict}/copyright_license.json")"
  copyright_year_first="$(jq -r -- .copyright.year.first "${i}")"
  copyright_year_last="$(jq -r -- .copyright.year.last "${i}")"
  description_text="$(jq -r -- .description.text "${i}")"
  disclaimer="$(jq -r -- .disclaimer[0] "${i}")"
  id="$(jq -r -- .id "${i}")"
  lang_bcp_47_full="$(jq -r -- ".\"${lang}\".bcp_47.full" "${dict}/language.json")"
  lang_dir="$(jq -r -- ".\"${lang}\".dir" "${dict}/language.json")"
  title_nested_text="$(jq -r -- .title.nested.text "${i}")"
  title_html="$(jq -r -- .title.html "${i}")"
  title_text="$(jq -r -- .title.text "${i}")"

  if [ "${title_nested_text}" != null ];then
    title_nested_html="$(jq -r -- .title.nested.html "${i}")"
  else
    title_nested_text="${title_text}"
    title_nested_html="${title_html}"
  fi
  
  # This is dumb
  #if [ "${lang}" = en ];then
  #  if printf '%s' "${title_text}" | grep -Fqe '“' -e '”';then
  #    if printf '%s' "${title_text}" | grep -Fqe "‘";then
  #      # Only convert ’ to ” if followed by a space or newline
  #      printf '%s' "${title_text}" | sed -e 's/“/'"‘/g" -e 's/”/'"’/g" -e "s/‘"'/“/g' \
  #                                        -e "s/’"'$/”/' -e "s/’"'\([^[:alnum:]_[:space:]]\)/”\1/g'
  #    else
  #      
  #    fi
  #  fi
  #fi

  canonical="https://gabl.ink/index/${id}/"

  if [ "${config_use_twitter}" = true ];then
    x_or_twitter=Twitter
  else
    x_or_twitter=X
  fi

  {
    printf '<!DOCTYPE html>'
  
    printf '<html lang="%s" dir="%s" xmlns="http://www.w3.org/1999/xhtml" xml:lang="%s">\n' \
           "${lang_bcp_47_full}" "${lang_dir}" "${lang_bcp_47_full}"
  
    printf '<!-- SPDX-License-Identifier: %s -->\n' "${copyright_license_spdx}"
  
    printf '<head>'
    printf '<meta charset="utf-8"/>'
    printf '<meta name="viewport" content="width=device-width,initial-scale=1"/>'
  
    printf '<title>gabl.ink – %s</title>' "${title_text}"
  
    printf '<meta name="description" content="%s"/>' "${description_text}"
    printf '<meta name="robots" content="index,follow"/>'
    printf '<link rel="canonical" href="%s" hreflang="%s" type="text/html"/>' "${canonical}" "${lang_bcp_47_full}"
  
    if [ "${type}" = comic_page ];then
      first_published_d="$(jq -r -- .first_published.d "${i}")"
      if [ "${#first_published_d}" -eq 1 ];then
        first_published_d_pad=0
      else
        unset first_published_d_pad
      fi
      first_published_m="$(jq -r -- .first_published.m "${i}")"
      if [ "${#first_published_m}" -eq 1 ];then
        first_published_m_pad=0
      else
        unset first_published_m_pad
      fi
      first_published_y="$(jq -r -- .first_published.y "${i}")"
      if   [ "${#first_published_y}" -eq 4 ];then
        unset first_published_y_pad
      elif [ "${#first_published_y}" -eq 3 ];then
        first_published_y_pad=0
      elif [ "${#first_published_y}" -eq 2 ];then
        first_published_y_pad=00
      elif [ "${#first_published_y}" -eq 1 ];then
        first_published_y_pad=000
      else
        error 'first_published_y is not 1–4 digits long'
      fi
      lang_ogp_full="$(jq -r -- ".\"${lang}\".ogp.full" "${dict}/language.json")"
      chapter="$(jq -r -- .location.chapter "${i}")"
      next_string="$(jq -r -- .location.next.string "${i}")"
      page_integer="$(jq -r -- .location.page.integer "${i}")"
      page_string="$(jq -r -- .location.page.string "${i}")"
      prev_string="$(jq -r -- .location.previous.string "${i}")"
      series="$(jq -r -- .location.series "${i}")"
      series_hashtag="$(jq -r -- .hashtag "${index}/${id}/../data.json")"
      series_title_disambiguation_html="$(jq -r -- .title.disambiguation.html "${index}/${id}/../data.json")"
      series_title_html="$(jq -r -- .title.html "${index}/${id}/../data.json")"
      series_title_text="$(jq -r -- .title.text "${index}/${id}/../data.json")"
      volume="$(jq -r -- .location.volume "${i}")"
  
      # For future reference: Each video should have a WebM (VP9/Opus) and MP4 (H.264/AAC) version.
      # WebM should be preferred due to being free (libre), and MP4 should be provided as a fallback for compatibility.
      # In case of a video, image.png should act as a thumbnail.
      if [ -f "${index}/${id}/video.webm" ];then
        video_exists=true
      else
        unset video_exists
      fi
  
      # Determine how many directories deep from the series the page is
      up_directories=4
  
      [ "${volume}" = null ] &&
        up_directories="$((up_directories-1))"
  
      [ "${chapter}" = null ] &&
        up_directories="$((up_directories-1))"
  
      styles="$(
        # ShellCheck warns “n” is unused, but that’s intentional
        # shellcheck disable=SC2034
        for n in $(seq 1 "${up_directories}");do
          printf ../
        done
        printf ../../cms/styles
      )"
  
      if   [ "${up_directories}" -eq 2 ];then
        container=series
      elif [ "${up_directories}" -eq 3 ];then
        container=chapter
      elif [ "${up_directories}" -eq 4 ];then
        container=volume
      else
        error 'up_directories is not 2, 3, or 4'
      fi
  
      printf '<link rel="preload" href="%s/global.css" as="style" hreflang="zxx" type="text/css"/>' \
             "${styles}"
      printf '<link rel="preload" href="%s/comic_page_%s.css" as="style" hreflang="zxx" type="text/css"/>' \
             "${styles}" "${series}"
      printf '<link rel="stylesheet" href="%s/global.css" hreflang="zxx" type="text/css"/>' \
             "${styles}"
      printf '<link rel="stylesheet" href="%s/comic_page_%s.css" hreflang="zxx" type="text/css"/>' \
             "${styles}" "${series}"
  
      printf '<link rel="license" href="%s" hreflang="en" type="text/html"/>' "${copyright_license_url}"
  
      if   [ "${up_directories}" -eq 2 ];then
        unset volume chapter
      elif [ "${up_directories}" -eq 3 ];then
        unset volume
        chapter="$(jq -r -- .location.chapter "${i}")"
      elif [ "${up_directories}" -eq 4 ];then
        volume="$(jq -r -- .location.volume "${i}")"
        chapter="$(jq -r -- .location.chapter "${i}")"
      fi

      container_pages_first_string="$(jq -r -- .pages.first.string "${index}/${id}/../data.json")"
      container_pages_last_string="$(jq -r -- .pages.last.string "${index}/${id}/../data.json")"
  
      if   [ "${prev_string}" = null ];then
        # This is the first page, so no prefetches are needed.
        true
      elif [ "${container_pages_first_string}" != "${page_string}" ] ||
           [ "${container_pages_first_string}" != "${prev_string}" ];then
        printf '<link rel="prefetch" href="../%s/" hreflang="%s" type="text/html"/>' \
               "${container_pages_first_string}" "${lang_bcp_47_full}"
        printf '<link rel="prev prefetch" href="../%s/" hreflang="%s" type="text/html"/>' \
               "${prev_string}" "${lang_bcp_47_full}"
      elif [ "${container_pages_first_string}" = "${prev_string}" ];then
        printf '<link rel="prev prefetch" href="../%s/" hreflang="%s" type="text/html"/>' \
               "${prev_string}" "${lang_bcp_47_full}"
      fi
  
      if   [ "${next_string}" = null ];then
        # This is the last page, so no prefetches are needed.
        true
      elif [ "${container_pages_last_string}" != "${page_string}" ] ||
           [ "${container_pages_last_string}" != "${next_string}" ];then
        printf '<link rel="next prefetch" href="../%s/" hreflang="%s" type="text/html"/>' \
               "${next_string}" "${lang_bcp_47_full}"
        printf '<link rel="prefetch" href="../%s/" hreflang="%s" type="text/html"/>' \
               "${container_pages_last_string}" "${lang_bcp_47_full}"
      elif [ "${container_pages_last_string}" = "${next_string}" ];then
        printf '<link rel="next prefetch" href="../%s/" hreflang="%s" type="text/html"/>' \
               "${next_string}" "${lang_bcp_47_full}"
      fi
  
      make_og type article
      make_og title "${title_text}"
      make_og description "${description_text}"
      make_og site_name gabl.ink
      make_og url "${canonical}"
      make_og image "${canonical}image.png"
      if [ "${video_exists}" = true ];then
        make_og video "${canonical}video.webm"
        make_og video "${canonical}video.mp4"
      fi
      make_og locale "${lang_ogp_full}"
  
      printf '</head>'
  
      printf '<body>'
      printf '<header>'
      printf '<a href="https://gabl.ink/">'
      printf '<picture id="gabldotink_logo">'
      printf '<img src="./logo.svg" alt="%s"/>' 'gabl.ink logo'
      printf '</picture></a></header>'
      printf '<main>'
      printf '<div id="nav_top">'
      printf '<h1 id="nav_top_title">'
      printf '“<cite>%s</cite>”</h1>' "${title_nested_html}"
  
      if [ "${container_pages_first_string}" != null ];then
        container_pages_first_title_text="$(jq -r -- .title.text "${index}/${id}/../${container_pages_first_string}/data.json")"
        container_pages_first_title_nested_text="$(jq -r -- .title.nested.text "${index}/${id}/../${container_pages_first_string}/data.json")"
        [ "${container_pages_first_title_nested_text}" = null ] &&
          container_pages_first_title_nested_text="${container_pages_first_title_text}"
      else
        unset container_pages_first_title_text container_pages_first_title_nested_text
      fi
  
      if [ "${prev_string}" != null ];then
        prev_title_text="$(jq -r -- .title.text "${index}/${id}/../${prev_string}/data.json")"
        prev_title_nested_text="$(jq -r -- .title.nested.text "${index}/${id}/../${prev_string}/data.json")"
        [ "${prev_title_nested_text}" = null ] &&
          prev_title_nested_text="${prev_title_text}"
      else
        unset prev_title_text prev_title_nested_text
      fi
  
      if [ "${next_string}" != null ];then
        next_title_text="$(jq -r -- .title.text "${index}/${id}/../${next_string}/data.json")"
        next_title_nested_text="$(jq -r -- .title.nested.text "${index}/${id}/../${next_string}/data.json")"
        [ "${next_title_nested_text}" = null ] &&
          next_title_nested_text="${next_title_text}"
      else
        unset next_title_text next_title_nested_text
      fi
  
      if [ "${container_pages_last_string}" != null ];then
        container_pages_last_title_text="$(jq -r -- .title.text "${index}/${id}/../${container_pages_last_string}/data.json")"
        container_pages_last_title_nested_text="$(jq -r -- .title.nested.text "${index}/${id}/../${container_pages_last_string}/data.json")"
        [ "${container_pages_last_title_nested_text}" = null ] &&
          container_pages_last_title_nested_text="${container_pages_last_title_text}"
      else
        unset container_pages_last_title_text container_pages_last_title_nested_text
      fi
  
      make_nav_buttons top
  
      printf '</div>'
  
      printf '<div id="comic_page_'
  
      # TODO: Edge case: one format exists, other doesn’t
      # TODO: Edge case: no captions
      # TODO: Browsers fix “id” for filesystems, but we should get better filenames, in addition to easy download links
      if [ "${video_exists}" = true ];then
        printf 'video"><video controls="" poster="./image.png" preload="metadata">'
        printf '<source src="./video.webm" type="video/webm"/>'
        printf '<source src="./video.mp4" type="video/mp4"/>'
        printf '<track default="" kind="captions" '

        printf 'label="English (United States) (CC)" '
        printf 'src="./track_en-us_cc.vtt" srclang="en-US"/>'
        printf '<p>It looks like your web browser doesn'"’"'t support the <code>video</code> element. You can download the video as a <a href="./video.webm" hreflang="en-US" type="video/webm" download="%s.webm">WebM</a> or <a href="./video.mp4" hreflang="en-US" type="video/mp4" download="%s.mp4">MP4</a> file to watch with your preferred video player. You can also view the transcript for the video at “Comic transcript” below.</p>' "${id}" "${id}"
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
  
      if [ "${container}" = series ];then
        printf '%s' "${series_title_html}"
        printf '</cite></i>'
  
        [ "${series_title_disambiguation_html}" != null ] &&
          printf ' %s' "${series_title_disambiguation_html}"
      fi
  
      printf ', page %s ' "${page_integer}"
  
      printf '“<cite>%s</cite>”' "${title_nested_html}"
  
      printf '</summary>'
  
      printf '<ol id="nav_bottom_list_pages">'
  
      find "${index}/${id}/.." -type f -path "${index}/${id}"'/../*/data.json' -exec sh -c '
        d="$1"
        p="$2"
        s="$(jq -r -- .location.page.string "${d}")"

        if [ "$(jq -r .title.nested.html "${d}")" != null ];then
            title_nested_html="$(jq -r -- .title.nested.html "${d}")"
        else
            title_nested_html="$(jq -r -- .title.html "${d}")"
        fi

        printf "<li>“"
  
        if [ "${s}" = "${p}" ];then
          printf "<b><cite>"
          printf "%s" "${title_nested_html}"
          printf "</cite></b>”</li>"
        else
          printf "<a href=\"../"
          printf "%s" "${s}"
          printf "/\" hreflang=\"en-US\" type=\"text/html\"><cite>"
          printf "%s" "${title_nested_html}"
          printf "</cite></a>”</li>"
        fi
      ' shell '{}' "${page_string}" ';'
  
      printf '</ol></details></div></div>'
  
      printf '<details id="comic_transcript" open="">'
  
      printf '<summary>Comic transcript</summary>'
  
      printf '<table id="comic_transcript_table">'
  
      printf '<thead><tr>'
      printf '<th scope="col">Speaker</th>'
      printf '<th scope="col">Text</th>'
      printf '</tr></thead>'
  
      for l in $(jq -r -- '.transcript.lines|to_entries|.[].key' "${i}");do
        h="$(jq -r -- ".transcript.lines[${l}].h" "${i}")"
        d="$(jq -r -- ".transcript.lines[${l}].d" "${i}")"
        if [ "${h}" = null ];then
          unset h
        fi
        printf '<tr>'
        printf '<th scope="row">%s</th>' "${h}"
        printf '<td><p>%s</p></td>' "${d}"
        printf '</tr>'
      done
  
      printf '</table></details>'
  
      printf '<p id="first_published">First published <time class="nw" datetime="'
  
      printf '%s-%s-%s' "${first_published_y_pad}${first_published_y}" \
                        "${first_published_m_pad}${first_published_m}" \
                        "${first_published_d_pad}${first_published_d}"
  
      printf '">'
  
      printf '%s ' "$(jq -r -- ".months.\"${lang}\"[$((first_published_m-1))]" "${dict}/month_gregorian.json")"
      printf '<span data-ssml-say-as="date" data-ssml-say-as-format="d">%s</span>, ' "${first_published_d}"
      if   [ "${#first_published_y}" -lt 4 ] &&
           [ "${first_published_y}" -ne 0 ];then
        if [ "${config_use_ce}" = true ];then
          printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">%s</span> <abbr title="Common Era">CE</abbr>' "${first_published_y}"
        else
          printf '<abbr title="anno Domini">AD</abbr> <span data-ssml-say-as="date" data-ssml-say-as-format="y">%s</span>' "${first_published_y}"
        fi
      elif [ "${first_published_y}" -eq 0 ];then
        if [ "${config_use_ce}" = true ];then
          printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">1</span> <abbr title="Before the Common Era">BCE</abbr>'
        else
          printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">1</span> <abbr title="before Christ">BC</abbr>'
        fi
      else
        printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">%s</span>' "${first_published_y}"
      fi
  
      printf '</time></p><article id="post_'
  
      for p in $(jq -r -- '.post|to_entries|.[].key' "${i}");do
        post_content="$(jq -r -- ".post[${p}].content.html" "${i}")"
        post_date_d="$(jq -r -- ".post[${p}].date.d" "${i}")"
        if [ "${#post_date_d}" -eq 1 ];then
          post_date_d_pad=0
        else
          unset post_date_d_pad
        fi
        post_date_m="$(jq -r -- ".post[${p}].date.m" "${i}")"
        if [ "${#post_date_m}" -eq 1 ];then
          post_date_m_pad=0
        else
          unset post_date_m_pad
        fi
        post_date_y="$(jq -r -- ".post[${p}].date.y" "${i}")"
        if   [ "${#post_date_y}" -eq 4 ];then
          unset post_date_y_pad
        elif [ "${#post_date_y}" -eq 3 ];then
          post_date_y_pad=0
        elif [ "${#post_date_y}" -eq 2 ];then
          post_date_y_pad=00
        elif [ "${#post_date_y}" -eq 1 ];then
          post_date_y_pad=000
        else
          error 'post_date_y is not 1–4 digits long'
        fi
  
        printf '%s-%s-%s">' "${post_date_y_pad}${post_date_y}" \
                            "${post_date_m_pad}${post_date_m}" \
                            "${post_date_d_pad}${post_date_d}"
  
        printf '<h2 class="nw">'
        printf '<time datetime="%s-%s-%s">' "${post_date_y_pad}${post_date_y}" \
                                            "${post_date_m_pad}${post_date_m}" \
                                            "${post_date_d_pad}${post_date_d}"
  
        printf '%s ' "$(jq -r -- ".months.\"${lang}\"[$((post_date_m-1))]" "${dict}/month_gregorian.json")"
        printf '<span data-ssml-say-as="date" data-ssml-say-as-format="d">%s</span>, ' "${post_date_d}"
        if   [ "${#post_date_y}" -lt 4 ] &&
             [ "${post_date_y}" -ne 0 ];then
          if [ "${config_use_ce}" = true ];then
            printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">%s</span> <abbr title="Common Era">CE</abbr>' "${first_published_y}"
          else
            printf '<abbr title="anno Domini">AD</abbr> <span data-ssml-say-as="date" data-ssml-say-as-format="y">%s</span>' "${first_published_y}"
          fi
        elif [ "${post_date_y}" -eq 0 ];then
          if [ "${config_use_ce}" = true ];then
            printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">1</span> <abbr title="Before the Common Era">BCE</abbr>'
          else
            printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">1</span> <abbr title="before Christ">BC</abbr>'
          fi
        else
          printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">%s</span>' "${first_published_y}"
        fi
  
        printf '</time></h2>'
  
        printf '%s' "${post_content}"
  
        printf '</article>'
      done
  
      printf '</main>'
  
      printf '<details id="share_links">'
      printf '<summary>Share this page</summary>'
      printf '<ul>'
  
      make_share_link x "${x_or_twitter}" https://x.com/intent/tweet text url hashtags \
                     "$(
                        printf 'gabl.ink @gabldotink: “%s”: “' "${series_title_text}"
                        printf '%s”' "${title_nested_text}"
                      )" \
                     "gabldotink,${series_hashtag}"
      
      make_share_link reddit Reddit 'https://www.reddit.com/submit?type=LINK' title url '' \
                     "$(
                        printf 'gabl.ink: “%s”: “' "${series_title_text}"
                        printf '%s”' "${title_nested_text}"
                      )"
      
      make_share_link facebook Facebook https://www.facebook.com/sharer/sharer.php '' u '' ''
      
      make_share_link telegram Telegram https://t.me/share text url '' \
                     "$(
                        printf 'gabl.ink: “%s”: “' "${series_title_text}"
                        printf '%s” ' "${title_nested_text}"
                        printf '#gabldotink #%s' "${series_hashtag}"
                      )"
      
      make_share_link bluesky Bluesky https://bsky.app/intent/compose text '' '' \
                     "$(
                        printf 'gabl.ink @gabl.ink: “%s”: “' "${series_title_text}"
                        printf '%s” ' "${title_nested_text}"
                        printf '%s ' "${canonical}"
                        printf '#gabldotink #%s' "${series_hashtag}"
                      )"
      
      make_share_link whatsapp WhatsApp https://wa.me/ text '' '' \
                     "$(
                        printf 'gabl.ink: “%s”: “' "${series_title_text}"
                        printf '%s” ' "${title_nested_text}"
                        printf '%s' "${canonical}"
                      )"
      
      make_share_link mastodon Mastodon https://mastodonshare.com/ text url '' \
                     "$(
                        printf 'gabl.ink @gabldotink@mstdn.party: “%s”: “' "${series_title_text}"
                        printf '%s” ' "${title_nested_text}"
                        printf '#gabldotink #%s' "${series_hashtag}"
                      )"
      
      make_share_link threads Threads https://www.threads.com/intent/post text url '' \
                     "$(
                        printf 'gabl.ink: “%s”: “' "${series_title_text}"
                        printf '%s” ' "${title_nested_text}"
                        printf '#gabldotink #%s' "${series_hashtag}"
                      )"
  
      make_share_link truthsocial 'Truth Social' https://truthsocial.com/share text url '' \
                     "$(
                        printf 'gabl.ink: “%s”: “' "${series_title_text}"
                        printf '%s” ' "${title_nested_text}"
                        printf '#gabldotink #%s' "${series_hashtag}"
                      )"
  
      make_share_link gab Gab https://gab.com/compose text url '' \
                     "$(
                        printf 'gabl.ink: “%s”: “' "${series_title_text}"
                        printf '%s” ' "${title_nested_text}"
                        printf '#gabldotink #%s' "${series_hashtag}"
                      )"
  
      printf '</ul></details>'

      printf '<details id="validate_links">'
      printf '<summary>Validate this page</summary>'
      printf '<ul>'

      make_validate_link vnu 'the Nu Html Checker' 'https://validator.nu/?doc=' '<abbr title="Hypertext Markup Language 5">HTML5</abbr>'
      make_validate_link w3c 'the <abbr title="World Wide Web Consortium">W3C</abbr> Markup Validation Service' \
                             'https://validator.w3.org/nu/?doc=' '<abbr title="Hypertext Markup Language 5">HTML5</abbr>'
    fi

    printf '</ul></details>'
  
    printf '<footer><p><span class="nw">'
    printf '<abbr title="Copyright">©</abbr> '
    printf '<time data-ssml-say-as="date" data-ssml-say-as-format="y">%s</time>' "${copyright_year_first}"
    [ "${copyright_year_last}" != null ] &&
      printf '–<time data-ssml-say-as="date" data-ssml-say-as-format="y">%s</time>' "${copyright_year_last}"
    printf '</span> <span translate="no" data-ssml-phoneme-alphabet="ipa" data-ssml-phoneme-ph="ˈɡæbəl dɒt ˈɪŋk">gabl.ink</span></p>'

    printf '<p>License: <a rel="external license" href="%s" ' "${copyright_license_url}"
    printf 'hreflang="en" type="text/html">'
    printf '%s' "${copyright_license_title}"
    [ "${copyright_license_abbr}" != null ] &&
      printf ' (<abbr>%s</abbr>)' "${copyright_license_abbr}"
    printf '</a></p>'

    if [ "${disclaimer}" != null ];then
      disclaimer_html="$(jq -r -- ".\"${disclaimer}\".\"${lang}\"" "${dict}/disclaimer.json")"
      printf '<p>Disclaimer: %s</p>' "${disclaimer_html}"
    else
      unset disclaimer_html
    fi

    printf '</footer>'
  
    printf '</body></html>\n'
  } > "${index}/${id}/index.html"
done

[ "${warning_warned}" = true ] &&
  [ "${config_exit_nonzero_with_warnings}" = true ] &&
    exit 2

# exit 0
