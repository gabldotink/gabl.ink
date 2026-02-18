#!/bin/sh
# SPDX-License-Identifier: CC0-1.0

export POSIXLY_CORRECT

trap \
 'printf "Exiting. No changes were made.\n"
  exit 1' \
  INT EXIT

script="$0"

dependencies='basename cat cut dirname exiftool find grep jq mktemp rm sh sha256sum tput'

for c in ${dependencies};do
  if command -v "${c}" >/dev/null 2>&1;then
    commands_v="${commands_v} ${c}"
  fi
done

for r in ${dependencies};do
  case "${commands_v} " in
    *" ${r} "*)
      true ;;
    *)
      printf '[error] This script requires the following programs to be installed in PATH: %s\n' "${dependencies}" >&2
      printf '        You have the following programs installed:%s\n' "${commands_v}" >&2
      printf '        Please install missing programs.\n' >&2
      exit 1
  esac
done

tput_colors="$(tput -- colors 2>/dev/null||true)"
tput_reset="$(tput -- sgr0 2>/dev/null||true)" 
if [ "${tput_colors}" -ge 256 ];then
  tput_link="$(tput -- setaf 21 2>/dev/null||true)$(tput -- smul 2>/dev/null||true)"
else
  tput_link="$(tput -- setaf 4 2>/dev/null||true)$(tput -- smul 2>/dev/null||true)"
fi

# Prevent sh -x from having link styling
if printf '%s' "$-" | grep -qF -- x;then
  printf '%s' "${tput_reset}" >&2
fi

# Display help if any arguments are passed
if [ "$#" -gt 0 ];then
  trap - INT EXIT

  printf 'Usage: %s\n\n' "${script}" >&2

  printf 'This script generates the gabl.ink website.\n' >&2
  printf 'It does not accept arguments.\n\n' >&2

  printf 'This script requires the following programs to be installed in PATH:\n' >&2
  printf '  %s\n' "${dependencies}" >&2
  printf 'You have all of these installed already.\n\n' >&2

  printf '© 2024–2026 gabl.ink\n' >&2
  printf 'License: CC0 1.0 Universal (CC0 1.0)\n' >&2
  printf '%shttps://creativecommons.org/publicdomain/zero/1.0/deed.en%s\n' "${tput_link}" "${tput_reset}" >&2

  exit 1
fi

scripts="$(dirname -- "${script}")"
cms="${scripts}/.."
dict="${cms}/dictionaries"
index="${cms}/../index"
encyclopedia="${index}/encyclopedia"
lib="${scripts}/lib"

# shellcheck source-path=./lib
for f in "${lib}/"*.sh;do
  . "${f}"
done

# We must use an if statement here to use a ShellCheck directive
if [ -f "${scripts}/config.sh" ];then
  # shellcheck source=./config.sh
  . "${scripts}/config.sh"
fi

if [ "${config_lang_default}" != en-US ];then
  lang_default="${config_lang_default}"
else
  lang_default=en-US
fi

#items="$(find "${index}" -type f -name data.json -print)"
items="${index}/jrco_beta/01/data.json ${index}/jrco_beta/02/data.json"

trap - INT EXIT

printf '[section start] items\n' >&2

for i in ${items};do (
  type="$(jq_r type "${i}")"
  id="$(jq_r id "${i}")"

  # This continue only exits this subshell, but that’s fine, since the subshell is the whole loop
  if [ "${type}" = comic_series ];then
    printf '[skip] %s/%s\n' "${id}" "${lang}"
    # shellcheck disable=2106
    continue
  fi

  lang_original="$(jq_r lang_original "${i}")"

  for lang in $(jq_r 'langs[]' "${index}/${id}/data.json");do (
    printf '[start] %s/%s\n' "${id}" "${lang}" >&2

    tmpfile="$(mktemp)"

    trap \
     'rm -f -- "${tmpfile}" >/dev/null 2>&1
      exit 1' \
    INT EXIT

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
    set_var_l10n title title "${i}"

    canonical="https://gabl.ink/index/${id}/${lang}/"

    # For now, the below is to add later.
    # For future reference: Each video should have a WebM (VP9/Opus) and MP4 (H.264/AAC) version.
    # WebM should be preferred due to being free (libre), and MP4 should be provided as a fallback for compatibility.
    # In case of a video, image.png should act as a thumbnail.
    if [ -f "${index}/${id}/${lang}/video.webm" ];then
      video_exists=true
    else
      unset video_exists
    fi

    if [ -f "${index}/${id}/${lang}/cc.vtt" ];then
      captions_exists=true
    else
      unset captions_exists
    fi

    if [ "$(jq_r tooltip "${i}")" != null ];then
      tooltip_exists=true
    else
      unset tooltip_exists
    fi

    {
      printf '<!DOCTYPE html>\n'
      printf '<!-- SPDX-License-Identifier: %s -->\n' "${copyright_license_spdx}"

      # shellcheck disable=2154
      printf '<html lang="%s" dir="%s" xmlns="http://www.w3.org/1999/xhtml" xml:lang="%s">' \
             "${lang}" "${lang_d}" "${lang}"

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
        if [ "${tooltip_exists}" = true ];then
          set_var_l10n tooltip tooltip "${i}"
        fi
        volume="$(jq_r location.volume "${i}")"

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

        printf '<link rel="external license" href="%s" hreflang="en" type="text/html"/>' "${copyright_license_url_id}"

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

        # TODO: Edge case: no captions
        if [ "${video_exists}" = true ];then
          printf 'video"><video controls="" poster="./image.png" preload="metadata"'
          if [ "${tooltip_exists}" = true ];then
            printf ' title="%s"' "${tooltip_text}"
          fi
          printf '>'
          printf '<source src="./video.webm" type="video/webm"/>'
          if [ "${captions_exists}" = true ];then
            printf '<track default="" kind="captions" '

            printf 'label="%s (%s) (CC)" ' "${lang_l_name_local_text}" "${lang_r_name_local_text}"
            printf 'src="./cc.vtt" srclang="%s"/>' "${lang}"
          fi
          # shellcheck disable=1112
          printf '<p>It looks like your web browser doesn’t support the <code>video</code> element. You can download the video as a <a href="./video.webm" hreflang="en-US" type="video/webm" download="%s_-_%s.webm">WebM</a> file to watch with your preferred video player. You can also view the transcript for the video at “Comic transcript” below.</p>' "${series_title_filename}" "${title_filename}"
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

        find "${index}/${id}/.." -type f -path "${index}/${id}"'/../*/data.json' -exec sh -c -- '
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
          if [ "$(jq_r name "${encyclopedia}/${l_h}/data.json")" = null ];then
            unset l_h_label
          else
            set_var_l10n l_h_label name.label "${encyclopedia}/${l_h}/data.json"
            test_null l_h_label &&
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
          printf '<abbr title="anno Domini">AD</abbr> <span data-ssml-say-as="date" data-ssml-say-as-format="y">%s</span>' "$  {first_published_y}"
        elif [ "${first_published_y}" -eq 0 ];then
          printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">1</span> <abbr title="before Christ">BC</abbr>'
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
            printf '<abbr title="anno Domini">AD</abbr> <span data-ssml-say-as="date" data-ssml-say-as-format="y">%s</span>' "$  {first_published_y}"
          elif [ "${post_date_y}" -eq 0 ];then
            printf '<span data-ssml-say-as="date" data-ssml-say-as-format="y">1</span> <abbr title="before Christ">BC</abbr>'
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

        make_share_link email \
                       "$(
                          printf 'gabl.ink: _%s_: “' "${series_title_text}"
                          printf '%s”' "${title_text}"
                        )" \
                       "$(
                          printf 'From https://gabl.ink/ : %s' "${canonical}"
                        )"

        make_share_link sms '' \
                       "$(
                          printf 'gabl.ink: _%s_: “' "${series_title_text}"
                          printf '%s” ' "${title_text}"
                          printf '%s' "${canonical}"
                          )"

        make_share_link x '' \
                       "$(
                          printf 'gabl.ink @gabldotink: _%s_: “' "${series_title_text}"
                          printf '%s”' "${title_text}"
                        )" \
                       "gabldotink,${series_hashtag_id}"

        make_share_link reddit \
                       "$(
                          printf 'gabl.ink: _%s_: “' "${series_title_text}"
                          printf '%s”' "${title_text}"
                        )"

        make_share_link facebook

        make_share_link telegram '' \
                       "$(
                          printf 'gabl.ink: _%s_: “' "${series_title_text}"
                          printf '%s” ' "${title_text}"
                          printf '#gabldotink #%s' "${series_hashtag_id}"
                        )"

        make_share_link bluesky '' \
                       "$(
                          printf 'gabl.ink @gabl.ink: _%s_: “' "${series_title_text}"
                          printf '%s” ' "${title_text}"
                          printf '%s ' "${canonical}"
                          printf '#gabldotink #%s' "${series_hashtag_id}"
                        )"

        make_share_link whatsapp '' \
                       "$(
                          printf 'gabl.ink: _%s_: “' "${series_title_text}"
                          printf '%s” ' "${title_text}"
                          printf '%s' "${canonical}"
                        )"

        make_share_link mastodon '' \
                       "$(
                          printf 'gabl.ink @gabldotink@mstdn.party: _%s_: “' "${series_title_text}"
                          printf '%s” ' "${title_text}"
                          printf '#gabldotink #%s' "${series_hashtag_id}"
                        )"

        make_share_link threads '' \
                       "$(
                          printf 'gabl.ink: _%s_: “' "${series_title_text}"
                          printf '%s” ' "${title_text}"
                          printf '#gabldotink #%s' "${series_hashtag_id}"
                        )"

        make_share_link truth_social '' \
                       "$(
                          printf 'gabl.ink: _%s_: “' "${series_title_text}"
                          printf '%s” ' "${title_text}"
                          printf '#gabldotink #%s' "${series_hashtag_id}"
                        )"

        make_share_link gab '' \
                       "$(
                          printf 'gabl.ink: _%s_: “' "${series_title_text}"
                          printf '%s” ' "${title_text}"
                          printf '#gabldotink #%s' "${series_hashtag_id}"
                        )"

        make_share_link vk \
                       "$(
                          printf 'gabl.ink: _%s_: “' "${series_title_text}"
                          printf '%s” ' "${title_text}"
                          )" \
                       "$(
                          printf 'From https://gabl.ink/ : %s ' "${canonical}"
                          printf '#gabldotink #%s' "${series_hashtag_id}"
                          )"

        printf '</ul></details>'

        printf '<details id="validate_links">'
        printf '<summary>Validate this page</summary>'
        printf '<ul>'

        make_validate_link vnu
        make_validate_link w3c
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
    } > "${tmpfile}"

    cat -- "${tmpfile}" > "${index}/${id}/${lang}/index.html"

    rm -f -- "${tmpfile}" >/dev/null 2>&1

    printf '[done] %s/%s\n' "${id}" "${lang}" >&2
    )
  done
  ) &
done

wait

printf '[section done] items\n' >&2

trap - INT EXIT

# TODO: Doesn’t work with subshells
[ "${warning_warned}" = true ] &&
  [ "${config_exit_nonzero_with_warnings}" = true ] &&
    exit 2

exit 0
