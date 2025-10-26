# shellcheck shell=sh
# shellcheck disable=SC2154
# SPDX-License-Identifier: CC0-1.0
# Do not run or source this file! It is meant to be sourced by ../build.sh only.

# TODO: Reduce duplicate code.
# TODO: Handle multiple chapters.
# TODO: Handle quotation marks in other page titles.
  
make_nav_buttons() {
  make_nav_buttons_l="$1"
  
  printf '<div id="nav_%s_buttons">' "${make_nav_buttons_l}"
  
  printf '<div class="nav_button" id="nav_%s_buttons_first" ' "${make_nav_buttons_l}"
  
  if [ "${container_pages_first_string}" = null ];then
    printf 'title="First in %s (This is the first page!)">' "${container}"
  else
    printf 'title="First in %s (“%s”)">' "${container}" "${container_pages_first_title_text}"
    printf '<a href="../%s/" hreflang="en-US" type="text/html">' "${container_pages_first_string}"
  fi
        
  printf '<p><span class="nav_button_arrow" data-ssml-sub-alias=" ">⇦</span><br/>First</p>'
  
  [ "${container_pages_first_string}" != null ] &&
    printf '</a>'
  
  printf '</div>'
  
  printf '<div class="nav_button" id="nav_%s_buttons_previous" ' "${make_nav_buttons_l}"
  
  if [ "${previous_string}" = null ];then
    printf 'title="Previous (This is the first page!)">'
  else
    printf 'title="Previous (“%s”)">' "${previous_title_text}"
    printf '<a href="../%s/" rel="prev" hreflang="en-US" type="text/html">' "${previous_string}"
  fi
  
  printf '<p><span class="nav_button_arrow" data-ssml-sub-alias=" ">←</span><br/>Previous</p>'
  
  [ "${previous_string}" != null ] &&
    printf '</a>'
  
  printf '</div>'
  
  printf '<div class="nav_button" id="nav_%s_buttons_next" ' "${make_nav_buttons_l}"
  
  if [ "${next_string}" = null ];then
    printf 'title="Next (This is the last page!)">'
  else
    printf 'title="Next (“%s”)">' "${next_title_text}"
    printf '<a href="../%s/" rel="next" hreflang="en-US" type="text/html">' "${next_string}"
  fi
  
  printf '<p><span class="nav_button_arrow" data-ssml-sub-alias=" ">→</span><br/>Next</p>'
  
  [ "${next_string}" != null ] &&
    printf '</a>'
  
  printf '</div>'
  
  printf '<div class="nav_button" id="nav_%s_buttons_last" ' "${make_nav_buttons_l}"
  
  if [ "${container_pages_last_string}" = null ];then
    printf 'title="Last in %s (This is the last page!)">' "${container}"
  else
    printf 'title="Last in %s (“%s”)">' "${container}" "${container_pages_last_title_text}"
    printf '<a href="../%s/" hreflang="en-US" type="text/html">' "${container_pages_last_string}"
  fi
  
  printf '<p><span class="nav_button_arrow" data-ssml-sub-alias=" ">⇨</span><br/>Last</p>'
  
  [ "${container_pages_last_string}" != null ] &&
    printf '</a>'
  
  printf '</div></div>'
}
