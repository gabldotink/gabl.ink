# shellcheck shell=sh
# shellcheck disable=SC2154
# SPDX-License-Identifier: CC0-1.0
# Do not run or source this file! It is meant to be sourced by ../build.sh only.

# TODO: Reduce duplicate code.
# TODO: Handle multiple chapters.
# TODO: Handle quotation marks in other page titles.

make_nav_buttons_first_last() {
  make_nav_buttons_first_last_d="$1"

  if   [ "${make_nav_buttons_first_last_d}" = '<' ];then
    make_nav_buttons_first_last_a=⇦
    make_nav_buttons_first_last_i=first
    make_nav_buttons_first_last_l=first
    make_nav_buttons_first_last_u=First
    make_nav_buttons_first_last_z=prev
  elif [ "${make_nav_buttons_first_last_d}" = '>' ];then
    make_nav_buttons_first_last_a=⇨
    make_nav_buttons_first_last_i=last
    make_nav_buttons_first_last_l=last
    make_nav_buttons_first_last_u=Last
    make_nav_buttons_first_last_z=next
  else
    error 'make_nav_buttons_first_last direction is not f or l'
  fi

  printf '<div class="nav_button" id="nav_%s_buttons_%s" ' "${make_nav_buttons_l}" "${make_nav_buttons_first_last_i}"

  if [ "$(eval 'printf "%s" "${'"${make_nav_buttons_first_last_z}"'}"')" = null ];then
    printf 'title="%s in %s (This is the %s page!)">' "${make_nav_buttons_first_last_u}" "${container}" "${make_nav_buttons_first_last_l}"
  else
    printf 'title="%s in %s (“%s”)">' "${make_nav_buttons_first_last_u}" "${container}" "$(eval 'printf "%s" "${container_'"${make_nav_buttons_first_last_i}"'_title_nested_text}"')"
    printf '<a href="../%s/" hreflang="en-US" type="text/html">' "$(zero_pad 2 "$(eval 'printf "%s" "${container_'"${make_nav_buttons_first_last_i}"'}"')")"
  fi

  printf '<p><span class="nav_button_arrow" data-ssml-sub-alias=" ">%s</span><br/>%s</p>' "${make_nav_buttons_first_last_a}" "${make_nav_buttons_first_last_u}"

  [ "$(eval 'printf "%s" "${container_'"${make_nav_buttons_first_last_i}"'}"')" != null ] &&
    printf '</a>'
  
  printf '</div>'
}

make_nav_buttons_prev_next() {
  make_nav_buttons_prev_next_d="$1"

  if   [ "${make_nav_buttons_prev_next_d}" = '<' ];then
    make_nav_buttons_prev_next_a=←
    make_nav_buttons_prev_next_i=prev
    # We don’t use this variable, but I’m keeping it in case other languages need it.
    # shellcheck disable=SC2034
    make_nav_buttons_prev_next_l=previous
    make_nav_buttons_prev_next_u=Previous
    make_nav_buttons_prev_next_z=first
  elif [ "${make_nav_buttons_prev_next_d}" = '>' ];then
    make_nav_buttons_prev_next_a=→
    make_nav_buttons_prev_next_i=next
    # shellcheck disable=SC2034
    make_nav_buttons_prev_next_l=next
    make_nav_buttons_prev_next_u=Next
    make_nav_buttons_prev_next_z=last
  else
    error 'make_nav_buttons_prev_next direction is not p or n'
  fi

  printf '<div class="nav_button" id="nav_%s_buttons_%s" ' "${make_nav_buttons_l}" "${make_nav_buttons_prev_next_i}"

  if [ "$(eval 'printf "%s" "${'"${make_nav_buttons_prev_next_i}"'}"')" = null ];then
    printf 'title="%s (This is the %s page!)">' "${make_nav_buttons_prev_next_u}" "${make_nav_buttons_prev_next_z}"
  else
    printf 'title="%s (“%s”)">' "${make_nav_buttons_prev_next_u}" "$(eval 'printf "%s" "${'"${make_nav_buttons_prev_next_i}"'_title_nested_text}"')"
    printf '<a href="../%s/" rel="%s" hreflang="en-US" type="text/html">' "$(zero_pad 2 "$(eval 'printf "%s" "${'"${make_nav_buttons_prev_next_i}"'}"')")" "${make_nav_buttons_prev_next_i}"
  fi

  printf '<p><span class="nav_button_arrow" data-ssml-sub-alias=" ">%s</span><br/>%s</p>' "${make_nav_buttons_prev_next_a}" "${make_nav_buttons_prev_next_u}"

  [ "$(eval 'printf "%s" "${'"${make_nav_buttons_prev_next_i}"'}"')" != null ] &&
    printf '</a>'
  
  printf '</div>'
}
  
make_nav_buttons() {
  make_nav_buttons_l="$1"
  
  printf '<div id="nav_%s_buttons">' "${make_nav_buttons_l}"
  
  make_nav_buttons_first_last '<'
  
  make_nav_buttons_prev_next '<'
  
  make_nav_buttons_prev_next '>'

  make_nav_buttons_first_last '>'

  printf '</div>'
}
