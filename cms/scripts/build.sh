#!/bin/sh
# SPDX-License-Identifier: CC0-1.0

export POSIXLY_CORRECT

script="$0"

scripts="$(dirname -- "${script}")"
cms="${scripts}/.."
dict="${cms}/dictionaries"
index="${cms}/../index"
encyclopedia="${index}/encyclopedia"
fifos="${scripts}/fifos"
lib="${scripts}/lib"

command -v jq >/dev/null 2>&1 ||
  error 'jq is not installed in PATH'

# shellcheck source=/dev/null
for f in "${lib}/"*.sh;do
  . "${f}"
done

# We must use an if statement here to use a ShellCheck directive
if [ -f "${scripts}/config/build.sh" ];then
  # shellcheck source=./config/build.sh
  . "${scripts}/config/build.sh"
fi

if [ "${config_lang_default}" != en-US ];then
  lang_default="${config_lang_default}"
else
  lang_default=en-US
fi

#items="$(find "${index}" -type f -name data.json)"
items="${index}/jrco_beta/01/data.json"

for i in ${items};do
  type="$(jq_r type "${i}")"

  [ "${type}" = comic_series ] &&
    continue

  #lang="$(jq_r language "${i}")"
  lang=en-US

  parse_lang

  copyright_license="$(jq_r copyright.license[0] "${i}")"
  # Literal quotation marks should be used when inserting variables into jq (hyphens can cause issues).
  # shellcheck disable=2016
  set_var_l10n copyright_license_abbr "\"${copyright_license}\".abbr" "${dict}/copyright_license.json"
  # shellcheck disable=2016
  set_var_l10n copyright_license_url "\"${copyright_license}\".url" "${dict}/copyright_license.json"
  copyright_license_spdx="$(jq -r --arg l "${copyright_license}" -- '.[$l].spdx' "${dict}/copyright_license.json")"
  # shellcheck disable=2016
  set_var_l10n copyright_license_title "\"${copyright_license}\".title" "${dict}/copyright_license.json"
  copyright_year_first="$(jq_r copyright.year.first "${i}")"
  copyright_year_last="$(jq_r copyright.year.last "${i}")"
  set_var_l10n description description "${i}"
  disclaimer="$(jq_r 'disclaimer[0]' "${i}")"
  id="$(jq_r id "${i}")"
  set_var_l10n title title "${i}"

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

  canonical="https://gabl.ink/index/${id}/${lang}/"

  # Covers two cases:
  # • If a named pipe (FIFO) cannot be created, a regular file will be created
  # • If the FIFO/file already exists, it will be truncated
  mkfifo "${fifos}/.build_output.html" >/dev/null 2>&1 ||
    true > "${fifos}/.build_output.html"

  {
    printf '<!DOCTYPE html>'

    # shellcheck disable=2154
    printf '<html lang="%s" dir="%s" xmlns="http://www.w3.org/1999/xhtml" xml:lang="%s">\n' \
           "${lang}" "${lang_d}" "${lang}"

    printf '<!-- SPDX-License-Identifier: %s -->\n' "${copyright_license_spdx}"

    printf '<head>'
    printf '<meta charset="utf-8"/>'
    printf '<meta name="viewport" content="width=device-width,initial-scale=1"/>'

    printf '<title>gabl.ink – “%s”</title>' "${title_text}"

    printf '<meta name="description" content="%s"/>' "${description_text}"
    printf '<meta name="robots" content="index,follow"/>'
    printf '<link rel="canonical" href="%s" hreflang="%s" type="text/html"/>' "${canonical}" "${lang_bcp_47_full}"

    if [ "${type}" = comic_page ];then
      first_published_d="$(jq_r first_published.d "${i}")"
      zero_pad 2 first_published_d
      first_published_m="$(jq_r first_published.m "${i}")"
      zero_pad 2 first_published_m
      first_published_y="$(jq_r first_published.y "${i}")"
      zero_pad 4 first_published_y
      chapter="$(jq_r location.chapter "${i}")"
      next="$(jq_r location.next "${i}")"
      page="$(jq_r location.page "${i}")"
      prev="$(jq_r location.previous "${i}")"
      series="$(jq_r location.series "${i}")"
      set_var_l10n series_hashtag hashtag "${index}/${id}/../data.json"
      set_var_l10n series_title title "${index}/${id}/../data.json"
      set_var_l10n tooltip tooltip "${i}"
      volume="$(jq_r location.volume "${i}")"

      # For future reference: Each video should have a WebM (VP9/Opus) and MP4 (H.264/AAC) version.
      # WebM should be preferred due to being free (libre), and MP4 should be provided as a fallback for compatibility.
      # In case of a video, image.png should act as a thumbnail.
      if [ -f "${index}/${id}/video.webm" ];then
        video_exists=true
      else
        unset video_exists
      fi

      if ! test_null tooltip_text;then
        tooltip_exists=true
      else
        unset tooltip_exists
      fi

      # Determine how many directories deep from the series the page is
      up_directories=4

      test_null volume &&
        up_directories="$((up_directories-1))"

      test_null chapter &&
        up_directories="$((up_directories-1))"

      styles="$(
        # ShellCheck warns “n” is unused, but that’s intentional
        # shellcheck disable=2034
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
        chapter="$(jq_r location.chapter "${i}")"
      elif [ "${up_directories}" -eq 4 ];then
        volume="$(jq_r location.volume "${i}")"
        chapter="$(jq_r location.chapter "${i}")"
      fi

      container_first="$(jq_r pages.first "${index}/${id}/../data.json")"
      container_last="$(jq_r pages.last "${index}/${id}/../data.json")"

      zero_pad 2 container_first
      zero_pad 2 container_last
      if ! test_null prev;then
        zero_pad 2 prev
      else
        unset zero_pad_2_prev
      fi
      if ! test_null next;then
        zero_pad 2 next
      else
        unset zero_pad_2_next
      fi
      zero_pad 2 page

      if test_null prev;then
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

      if test_null next;then
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
      make_og locale "${lang_l}_${lang_r}"

      printf '</head>'

      printf '<body>'
      printf '<header>'
      printf '<a href="https://gabl.ink/" id="gabldotink_logo">'
      printf 'gabl.ink'
      printf '</a></header>'
      printf '<div id="panels">'
      printf '<div id="nav_top">'
      printf '<h1 id="nav_top_title">'
      printf '“<cite>%s</cite>”</h1>' "${title_html}"

      if ! test_null container_first;then
        set_var_l10n container_first_title title "${index}/${id}/../${zero_pad_2_container_first}/data.json"
      else
        unset container_first_title_text
      fi

      if ! test_null prev;then
        set_var_l10n prev_title title "${index}/${id}/../${zero_pad_2_prev}/data.json"
      else
        unset prev_title_text
      fi

      if ! test_null next;then
        set_var_l10n next_title title "${index}/${id}/../${zero_pad_2_next}/data.json"
      else
        unset next_title_text
      fi

      if ! test_null container_last;then
        set_var_l10n container_last_title title "${index}/${id}/../${zero_pad_2_container_last}/data.json"
      else
        unset container_last_title_text
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
        # shellcheck disable=1112
        printf '<p>It looks like your web browser doesn’t support the <code>video</code> element. You can download the video as a <a href="./video.webm" hreflang="en-US" type="video/webm" download="%s.webm">WebM</a> or <a href="./video.mp4" hreflang="en-US" type="video/mp4" download="%s.mp4">MP4</a> file to watch with your preferred video player. You can also view the transcript for the video at “Comic transcript” below.</p>' "${id}" "${id}"
        printf '</video></div>'
      else
        printf 'image"><picture'
        [ "${tooltip_exists}" = true ] &&
          printf ' title="%s"' "${tooltip_text}"
        printf '>'
        printf '<img src="./image.png" alt="See “Comic transcript” below"/>'
        printf '</picture></div>'
      fi

      printf '<div id="nav_bottom">'

      make_nav_buttons bottom

      printf '<nav id="nav_bottom_list">'

      printf '<details id="nav_bottom_list_root">'

      printf '<summary>'

      printf '<cite class="i">'

      # TODO: Support higher containers (volumes and chapters).

      if [ "${container}" = series ];then
        printf '%s' "${series_title_html}"
        printf '</cite>'
      fi

      printf ', page %s ' "${page}"

      printf '“<cite>%s</cite>”' "${title_html}"

      printf '</summary>'

      printf '<ol id="nav_bottom_list_pages">'

      find "${index}/${id}/.." -type f -path "${index}/${id}"'/../*/data.json' -exec sh -c '
        [ -n "$1" ] &&
          set -x
        
        zero_pad_2_page="$2"
        lib="$3"
        lang="$4"
        lang_l="$5"
        lang_default="$6"

        for f in "${lib}/"*.sh;do
          . "${f}"
        done
        
        make_page_list_entry "$7"' \
        sh "$(printf '%s' "$-"|grep -F -- x)" "${zero_pad_2_page}" "${lib}" \
           "${lang}" "${lang_l}" "${lang_default}" '{}' ';'

      printf '</ol></details></nav></div>'

      printf '<details id="comic_transcript" open="">'

      printf '<summary>Comic transcript</summary>'

      printf '<table id="comic_transcript_table">'

      printf '<thead><tr>'
      printf '<th scope="col">Speaker</th>'
      printf '<th scope="col">Text</th>'
      printf '</tr></thead>'

      for l in $(jq_r 'transcript.lines|to_entries|.[].key' "${i}");do
        # shellcheck disable=2016
        l_h="$(jq -r --argjson l "${l}" -- '.transcript.lines[$l].h' "${i}")"
        set_var_l10n l_d "transcript.lines[${l}].d" "${i}"

        l_h_type="$(jq_r type "${encyclopedia}/${l_h}/data.json")"
        [ "${l_h_type}" = character ] ||
          [ "${l_h_type}" = meta_character ] ||
            error 'l_h_type is not character or meta_character'
        set_var_l10n l_h_label name.label "${encyclopedia}/${l_h}/data.json"
        if test_null l_h_label;then
          set_var_l10n l_h_label name.given "${encyclopedia}/${l_h}/data.json"
        fi

        printf '<tr>'
        # shellcheck disable=2154
        printf '<th scope="row">%s</th>' "${l_h_label_html}"
        # shellcheck disable=2154
        printf '<td><p>%s</p></td>' "${l_d_html}"
        printf '</tr>'
      done

      printf '</table></details>'

      printf '<p id="first_published">First published <time class="nw" datetime="'

      printf '%s-%s-%s' "${zero_pad_4_first_published_y}" \
                        "${zero_pad_2_first_published_m}" \
                        "${zero_pad_2_first_published_d}"

      printf '">'

      set_var_l10n first_published_m 'months['"$((first_published_m-1))]" "${dict}/month_gregorian.json"

      printf '%s ' "${first_published_m_html}"
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

      for p in $(jq_r 'post|to_entries|.[].key' "${i}");do
        set_var_l10n post_content 'post.['"${p}].content" "${i}"
        post_date_d="$(jq -r --argjson p "${p}" -- '.post[$p].date.d' "${i}")"
        zero_pad 2 post_date_d
        post_date_m="$(jq -r --argjson p "${p}" -- '.post[$p].date.m' "${i}")"
        zero_pad 2 post_date_m
        post_date_y="$(jq -r --argjson p "${p}" -- '.post[$p].date.y' "${i}")"
        zero_pad 4 post_date_y

        printf '%s-%s-%s">' "${zero_pad_4_post_date_y}" \
                            "${zero_pad_2_post_date_m}" \
                            "${zero_pad_2_post_date_d}"

        printf '<h2 class="nw">'
        printf '<time datetime="%s-%s-%s">' "${zero_pad_4_post_date_y}" \
                                            "${zero_pad_2_post_date_m}" \
                                            "${zero_pad_2_post_date_d}"

        set_var_l10n post_date_m 'months['"$((post_date_m-1))]" "${dict}/month_gregorian.json"

        printf '%s ' "${post_date_m_html}"
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

        printf '%s' "${post_content_html}"

        printf '</article>'
      done

      printf '<details id="share_links">'
      printf '<summary>Share this page</summary>'
      printf '<ul>'

      make_share_link x X https://x.com/intent/tweet text url hashtags \
                     "$(
                        printf 'gabl.ink @gabldotink: “%s”: “' "${series_title_text}"
                        printf '%s”' "${title_text}"
                      )" \
                     "gabldotink,${series_hashtag}"

      make_share_link reddit Reddit 'https://www.reddit.com/submit?type=LINK' title url '' \
                     "$(
                        printf 'gabl.ink: “%s”: “' "${series_title_text}"
                        printf '%s”' "${title_text}"
                      )"

      make_share_link facebook Facebook https://www.facebook.com/sharer/sharer.php '' u

      make_share_link telegram Telegram https://t.me/share text url '' \
                     "$(
                        printf 'gabl.ink: “%s”: “' "${series_title_text}"
                        printf '%s” ' "${title_text}"
                        printf '#gabldotink #%s' "${series_hashtag}"
                      )"

      make_share_link bluesky Bluesky https://bsky.app/intent/compose text '' '' \
                     "$(
                        printf 'gabl.ink @gabl.ink: “%s”: “' "${series_title_text}"
                        printf '%s” ' "${title_text}"
                        printf '%s ' "${canonical}"
                        printf '#gabldotink #%s' "${series_hashtag}"
                      )"

      make_share_link whatsapp WhatsApp https://wa.me/ text '' '' \
                     "$(
                        printf 'gabl.ink: “%s”: “' "${series_title_text}"
                        printf '%s” ' "${title_text}"
                        printf '%s' "${canonical}"
                      )"

      make_share_link mastodon Mastodon https://mastodonshare.com/ text url '' \
                     "$(
                        printf 'gabl.ink @gabldotink@mstdn.party: “%s”: “' "${series_title_text}"
                        printf '%s” ' "${title_text}"
                        printf '#gabldotink #%s' "${series_hashtag}"
                      )"

      make_share_link threads Threads https://www.threads.com/intent/post text url '' \
                     "$(
                        printf 'gabl.ink: “%s”: “' "${series_title_text}"
                        printf '%s” ' "${title_text}"
                        printf '#gabldotink #%s' "${series_hashtag}"
                      )"

      make_share_link truth_social 'Truth Social' https://truthsocial.com/share text url '' \
                     "$(
                        printf 'gabl.ink: “%s”: “' "${series_title_text}"
                        printf '%s” ' "${title_text}"
                        printf '#gabldotink #%s' "${series_hashtag}"
                      )"

      make_share_link gab Gab https://gab.com/compose text url '' \
                     "$(
                        printf 'gabl.ink: “%s”: “' "${series_title_text}"
                        printf '%s” ' "${title_text}"
                        printf '#gabldotink #%s' "${series_hashtag}"
                      )"

      printf '</ul></details>'

      printf '<details id="validate_links">'
      printf '<summary>Validate this page</summary>'
      printf '<ul>'

      make_validate_link vnu 'the <cite>Nu Html Checker</cite>' 'https://validator.nu/?doc=' '<abbr title="Hypertext Markup Language 5">HTML5</abbr>'
      make_validate_link w3c 'the <cite><abbr title="World Wide Web Consortium">W3C</abbr> Markup Validation Service</cite>' \
                             'https://validator.w3.org/nu/?doc=' '<abbr title="Hypertext Markup Language 5">HTML5</abbr>'
    fi

    printf '</ul></details>'

    printf '<footer><p><span class="nw">'
    printf '<abbr title="Copyright">©</abbr> '
    printf '<time data-ssml-say-as="date" data-ssml-say-as-format="y">%s</time>' "${copyright_year_first}"
    ! test_null copyright_year_last &&
      printf '–<time data-ssml-say-as="date" data-ssml-say-as-format="y">%s</time>' "${copyright_year_last}"
    printf '</span> <span translate="no" data-ssml-phoneme-alphabet="ipa" data-ssml-phoneme-ph="ˈɡæbəl dɒt ˈɪŋk">gabl.ink</span></p>'

    printf '<p>License: <a rel="external license" href="%s" ' "${copyright_license_url_id}"
    printf 'hreflang="en" type="text/html">'
    printf '<cite>%s</cite>' "${copyright_license_title_html}"
    ! test_null copyright_license_abbr &&
      printf ' (<cite class="nw"><abbr>%s</abbr></cite>)' "${copyright_license_abbr_html}"
    printf '</a></p>'

    if ! test_null disclaimer;then
      set_var_l10n disclaimer "\"${disclaimer}\"" "${dict}/disclaimer.json"
      printf '<p>Disclaimer: %s</p>' "${disclaimer_html}"
    else
      unset disclaimer_html
    fi

    printf '</footer>'

    printf '</div>'

    printf '</body></html>\n'
  } > "${fifos}/.build_output.html"
done

cat "${fifos}/.build_output.html" > "${index}/${id}/${lang}/index.html"
rm "${fifos}/.build_output.html"

[ "${warning_warned}" = true ] &&
  [ "${config_exit_nonzero_with_warnings}" = true ] &&
    exit 2

# exit 0
