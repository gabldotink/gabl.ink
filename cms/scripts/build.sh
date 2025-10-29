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

error(){
  error_msg="$1"
  error_exit_code="$2"
  printf 'error: '
  [ -n "${id}" ] &&
    printf '%s: ' "${id}"
  printf '%s\n' "${error_msg}"
  if [ -n "${error_exit_code}" ];then
    exit "${error_exit_code}"
  else
    exit 1
  fi
}

warning(){
  warning_msg="$1"
  warning_exit_code="$2"
  printf 'warning: '
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

load_lib(){
  load_lib_file="$1.sh"
  # shellcheck source=/dev/null
  . "${scripts}/lib/${load_lib_file}"
  # || error '%s/lib/%s could not be loaded' "$scripts" "$load_lib_file"
  # The shell gives its own error
}

jqr(){
  jq -r -- "$@"
}

command -v jq >/dev/null 2>&1 ||
  error 'jq is not installed in PATH'

load_lib make_og
load_lib make_nav_buttons
load_lib make_share_link
load_lib make_validate_link
load_lib set_var_mul
load_lib zero_pad

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
  type="$(jqr .type "${i}")"

  [ "${type}" = comic_series ] &&
    continue

  lang="$(jqr .language "${i}")"

  copyright_license="$(jqr .copyright.license[0] "${i}")"
  # Literal quotation marks should be used when inserting variables into jq (hyphens can cause issues).
  # shellcheck disable=SC2016
  set_var_mul copyright_license_abbr '\"${copyright_license}\".abbr' '"${dict}/copyright_license.json"'
  # shellcheck disable=SC2016
  set_var_mul copyright_license_url '\"${copyright_license}\".url' '"${dict}/copyright_license.json"'
  copyright_license_spdx="$(jqr ".\"${copyright_license}\".spdx" "${dict}/copyright_license.json")"
  # shellcheck disable=SC2016
  set_var_mul copyright_license_title '\"${copyright_license}\".title' '"${dict}/copyright_license.json"'
  copyright_year_first="$(jqr .copyright.year.first "${i}")"
  copyright_year_last="$(jqr .copyright.year.last "${i}")"
  description_text="$(jqr .description.text "${i}")"
  disclaimer="$(jqr .disclaimer[0] "${i}")"
  id="$(jqr .id "${i}")"
  lang_bcp_47_full="$(jqr ".\"${lang}\".bcp_47.full" "${dict}/language.json")"
  lang_dir="$(jqr ".\"${lang}\".dir" "${dict}/language.json")"
  title_nested_text="$(jqr .title.nested.text "${i}")"
  title_html="$(jqr .title.html "${i}")"
  title_text="$(jqr .title.text "${i}")"

  if [ "${title_nested_text}" != null ];then
    title_nested_html="$(jqr .title.nested.html "${i}")"
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
      first_published_d="$(jqr .first_published.d "${i}")"
      zero_pad_2_first_published_d="$(zero_pad 2 "${first_published_d}")"
      first_published_m="$(jqr .first_published.m "${i}")"
      zero_pad_2_first_published_m="$(zero_pad 2 "${first_published_m}")"
      first_published_y="$(jqr .first_published.y "${i}")"
      zero_pad_4_first_published_y="$(zero_pad 4 "${first_published_y}")"
      lang_ogp_full="$(jqr ".\"${lang}\".ogp.full" "${dict}/language.json")"
      chapter="$(jqr .location.chapter "${i}")"
      next="$(jqr .location.next "${i}")"
      page="$(jqr .location.page "${i}")"
      prev="$(jqr .location.previous "${i}")"
      series="$(jqr .location.series "${i}")"
      series_hashtag="$(jqr .hashtag "${index}/${id}/../data.json")"
      series_title_html="$(jqr .title.html "${index}/${id}/../data.json")"
      series_title_text="$(jqr .title.text "${index}/${id}/../data.json")"
      volume="$(jqr .location.volume "${i}")"

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
        chapter="$(jqr .location.chapter "${i}")"
      elif [ "${up_directories}" -eq 4 ];then
        volume="$(jqr .location.volume "${i}")"
        chapter="$(jqr .location.chapter "${i}")"
      fi

      container_first="$(jqr .pages.first "${index}/${id}/../data.json")"
      container_last="$(jqr .pages.last "${index}/${id}/../data.json")"

      zero_pad_2_container_first="$(zero_pad 2 "${container_first}")"
      zero_pad_2_container_last="$(zero_pad 2 "${container_last}")"
      [ "${prev}" != null ] &&
        zero_pad_2_prev="$(zero_pad 2 "${prev}")"
      [ "${next}" != null ] &&
        zero_pad_2_next="$(zero_pad 2 "${next}")"
      zero_pad_2_page="$(zero_pad 2 "${page}")"

      if   [ "${prev}" = null ];then
        # This is the first page, so no prefetches are needed.
        true
      elif [ "${container_first}" != "${page}" ] ||
           [ "${container_first}" != "${prev}" ];then
        printf '<link rel="prefetch" href="../%s/" hreflang="%s" type="text/html"/>' \
               "${zero_pad_2_container_first}" "${lang_bcp_47_full}"
        printf '<link rel="prev prefetch" href="../%s/" hreflang="%s" type="text/html"/>' \
               "${zero_pad_2_prev}" "${lang_bcp_47_full}"
      elif [ "${container_first}" = "${prev}" ];then
        printf '<link rel="prev prefetch" href="../%s/" hreflang="%s" type="text/html"/>' \
               "${zero_pad_2_prev}" "${lang_bcp_47_full}"
      fi

      if   [ "${next}" = null ];then
        # This is the last page, so no prefetches are needed.
        true
      elif [ "${container_last}" != "${page}" ] ||
           [ "${container_last}" != "${next}" ];then
        printf '<link rel="next prefetch" href="../%s/" hreflang="%s" type="text/html"/>' \
               "${zero_pad_2_next}" "${lang_bcp_47_full}"
        printf '<link rel="prefetch" href="../%s/" hreflang="%s" type="text/html"/>' \
               "${zero_pad_2_container_last}" "${lang_bcp_47_full}"
      elif [ "${container_last}" = "${next}" ];then
        printf '<link rel="next prefetch" href="../%s/" hreflang="%s" type="text/html"/>' \
               "${zero_pad_2_next}" "${lang_bcp_47_full}"
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

      if [ "${container_first}" != null ];then
        container_first_title_text="$(jqr .title.text "${index}/${id}/../${zero_pad_2_container_first}/data.json")"
        container_first_title_nested_text="$(jqr .title.nested.text "${index}/${id}/../${zero_pad_2_container_first}/data.json")"
        [ "${container_first_title_nested_text}" = null ] &&
          container_first_title_nested_text="${container_first_title_text}"
      else
        unset container_first_title_text container_first_title_nested_text
      fi

      if [ "${prev}" != null ];then
        prev_title_text="$(jqr .title.text "${index}/${id}/../${zero_pad_2_prev})/data.json")"
        prev_title_nested_text="$(jqr .title.nested.text "${index}/${id}/../${zero_pad_2_prev}/data.json")"
        [ "${prev_title_nested_text}" = null ] &&
          prev_title_nested_text="${prev_title_text}"
      else
        unset prev_title_text prev_title_nested_text
      fi

      if [ "${next}" != null ];then
        next_title_text="$(jqr .title.text "${index}/${id}/../${zero_pad_2_next}/data.json")"
        next_title_nested_text="$(jqr .title.nested.text "${index}/${id}/../${zero_pad_2_next}/data.json")"
        [ "${next_title_nested_text}" = null ] &&
          next_title_nested_text="${next_title_text}"
      else
        unset next_title_text next_title_nested_text
      fi

      if [ "${container_last}" != null ];then
        container_last_title_text="$(jqr .title.text "${index}/${id}/../${zero_pad_2_container_last}/data.json")"
        container_last_title_nested_text="$(jqr .title.nested.text "${index}/${id}/../${zero_pad_2_container_last}/data.json")"
        [ "${container_last_title_nested_text}" = null ] &&
          container_last_title_nested_text="${container_last_title_text}"
      else
        unset container_last_title_text container_last_title_nested_text
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
        # shellcheck disable=SC1112
        printf '<p>It looks like your web browser doesn’t support the <code>video</code> element. You can download the video as a <a href="./video.webm" hreflang="en-US" type="video/webm" download="%s.webm">WebM</a> or <a href="./video.mp4" hreflang="en-US" type="video/mp4" download="%s.mp4">MP4</a> file to watch with your preferred video player. You can also view the transcript for the video at “Comic transcript” below.</p>' "${id}" "${id}"
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
      fi

      printf ', page %s ' "${page}"

      printf '“<cite>%s</cite>”' "${title_nested_html}"

      printf '</summary>'

      printf '<ol id="nav_bottom_list_pages">'

      find "${index}/${id}/.." -type f -path "${index}/${id}"'/../*/data.json' -exec sh -c '
        d="$1"
        p="$2"
        s="$(printf "%02d" "$(jq -r -- .location.page "${d}")")"

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
      ' shell '{}' "${zero_pad_2_page}" ';'

      printf '</ol></details></div></div>'

      printf '<details id="comic_transcript" open="">'

      printf '<summary>Comic transcript</summary>'

      printf '<table id="comic_transcript_table">'

      printf '<thead><tr>'
      printf '<th scope="col">Speaker</th>'
      printf '<th scope="col">Text</th>'
      printf '</tr></thead>'

      for l in $(jqr '.transcript.lines|to_entries|.[].key' "${i}");do
        h="$(jqr ".transcript.lines[${l}].h" "${i}")"
        d="$(jqr ".transcript.lines[${l}].d" "${i}")"
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

      printf '%s-%s-%s' "${zero_pad_4_first_published_y}" \
                        "${zero_pad_2_first_published_m}" \
                        "${zero_pad_2_first_published_d}"

      printf '">'

      printf '%s ' "$(jqr ".months.\"${lang}\"[$((first_published_m-1))]" "${dict}/month_gregorian.json")"
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

      for p in $(jqr '.post|to_entries|.[].key' "${i}");do
        post_content="$(jqr ".post[${p}].content.html" "${i}")"
        post_date_d="$(jqr ".post[${p}].date.d" "${i}")"
        zero_pad_2_post_date_d="$(zero_pad 2 "${post_date_d}")"
        post_date_m="$(jqr ".post[${p}].date.m" "${i}")"
        zero_pad_2_post_date_m="$(zero_pad 2 "${post_date_m}")"
        post_date_y="$(jqr ".post[${p}].date.y" "${i}")"
        zero_pad_4_post_date_y="$(zero_pad 4 "${post_date_y}")"

        printf '%s-%s-%s">' "${zero_pad_4_post_date_y}" \
                            "${zero_pad_2_post_date_m}" \
                            "${zero_pad_2_post_date_d}"

        printf '<h2 class="nw">'
        printf '<time datetime="%s-%s-%s">' "${zero_pad_4_post_date_y}" \
                                            "${zero_pad_2_post_date_m}" \
                                            "${zero_pad_2_post_date_d}"

        printf '%s ' "$(jqr ".months.\"${lang}\"[$((post_date_m-1))]" "${dict}/month_gregorian.json")"
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

      make_validate_link vnu 'the <cite>Nu Html Checker</cite>' 'https://validator.nu/?doc=' '<abbr title="Hypertext Markup Language 5">HTML5</abbr>'
      make_validate_link w3c 'the <cite><abbr title="World Wide Web Consortium">W3C</abbr> Markup Validation Service</cite>' \
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
    printf '<cite>%s</cite>' "${copyright_license_title}"
    [ "${copyright_license_abbr}" != null ] &&
      printf ' (<cite><abbr>%s</abbr></cite>)' "${copyright_license_abbr}"
    printf '</a></p>'

    if [ "${disclaimer}" != null ];then
      disclaimer_html="$(jqr ".\"${disclaimer}\".\"${lang}\"" "${dict}/disclaimer.json")"
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
