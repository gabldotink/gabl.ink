# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

# TODO: Reduce duplicate code.
# TODO: Handle multiple chapters.
# TODO: Handle quotation marks in other page titles.

make_nav_buttons_f_l(){
  make_nav_buttons_f_l_d="$1"

  if   [ "${make_nav_buttons_f_l_d}" = '<' ];then
    make_nav_buttons_f_l_a=⇦
    make_nav_buttons_f_l_i=first
    make_nav_buttons_f_l_l=first
    make_nav_buttons_f_l_u=First
    make_nav_buttons_f_l_z=prev
  elif [ "${make_nav_buttons_f_l_d}" = '>' ];then
    make_nav_buttons_f_l_a=⇨
    make_nav_buttons_f_l_i=last
    make_nav_buttons_f_l_l=last
    make_nav_buttons_f_l_u=Last
    make_nav_buttons_f_l_z=next
  else
    error 'make_nav_buttons_f_l direction is not < or >'
  fi

  printf '<div class="nav_button" id="nav_%s_buttons_%s" ' "${make_nav_buttons_l}" "${make_nav_buttons_f_l_i}"

  if [ "$(eval 'printf "%s" "${'"${make_nav_buttons_f_l_z}"'}"')" = null ];then
    printf 'title="%s in %s (This is the %s page!)">' "${make_nav_buttons_f_l_u}" "${container}" "${make_nav_buttons_f_l_l}"
  else
    printf 'title="%s in %s (“%s”)">' "${make_nav_buttons_f_l_u}" "${container}" "$(eval 'printf "%s" "${container_'"${make_nav_buttons_f_l_i}"'_title_text}"')"
    printf '<a href="../../%s/%s/" hreflang="%s" type="text/html">' "$(printf '%02d' "$(eval 'printf "%s" "${container_'"${make_nav_buttons_f_l_i}"'}"')")" "${lang}" "${lang}"
  fi

  printf '<p><span class="nav_button_arrow" aria-hidden="true" data-ssml-sub-alias=" ">%s</span><br/>%s</p>' "${make_nav_buttons_f_l_a}" "${make_nav_buttons_f_l_u}"

  [ "$(eval 'printf "%s" "${container_'"${make_nav_buttons_f_l_i}"'}"')" != null ] &&
    printf '</a>'

  printf '</div>'
}

make_nav_buttons_p_n(){
  make_nav_buttons_p_n_d="$1"

  if   [ "${make_nav_buttons_p_n_d}" = '<' ];then
    make_nav_buttons_p_n_a=←
    make_nav_buttons_p_n_i=prev
    # We don’t use this variable, but I’m keeping it in case other languages need it.
    # shellcheck disable=2034
    make_nav_buttons_p_n_l=previous
    make_nav_buttons_p_n_u=Previous
    make_nav_buttons_p_n_z=first
  elif [ "${make_nav_buttons_p_n_d}" = '>' ];then
    make_nav_buttons_p_n_a=→
    make_nav_buttons_p_n_i=next
    # shellcheck disable=2034
    make_nav_buttons_p_n_l=next
    make_nav_buttons_p_n_u=Next
    make_nav_buttons_p_n_z=last
  else
    error 'make_nav_buttons_p_n direction is not < or >'
  fi

  printf '<div class="nav_button" id="nav_%s_buttons_%s" ' "${make_nav_buttons_l}" "${make_nav_buttons_p_n_i}"

  if [ "$(eval 'printf "%s" "${'"${make_nav_buttons_p_n_i}"'}"')" = null ];then
    printf 'title="%s (This is the %s page!)">' "${make_nav_buttons_p_n_u}" "${make_nav_buttons_p_n_z}"
  else
    printf 'title="%s (“%s”)">' "${make_nav_buttons_p_n_u}" "$(eval 'printf "%s" "${'"${make_nav_buttons_p_n_i}"'_title_text}"')"
    printf '<a href="../../%s/%s/" rel="%s" hreflang="%s" type="text/html">' "$(printf '%02d' "$(eval 'printf "%s" "${'"${make_nav_buttons_p_n_i}"'}"')")" "${lang}" "${make_nav_buttons_p_n_i}" "${lang}"
  fi

  printf '<p><span class="nav_button_arrow" aria-hidden="true" data-ssml-sub-alias=" ">%s</span><br/>%s</p>' "${make_nav_buttons_p_n_a}" "${make_nav_buttons_p_n_u}"

  [ "$(eval 'printf "%s" "${'"${make_nav_buttons_p_n_i}"'}"')" != null ] &&
    printf '</a>'

  printf '</div>'
}

make_nav_buttons(){
  make_nav_buttons_l="$1"

  printf '<nav id="nav_%s_buttons">' "${make_nav_buttons_l}"

  make_nav_buttons_f_l '<'
  make_nav_buttons_p_n '<'
  make_nav_buttons_p_n '>'
  make_nav_buttons_f_l '>'

  printf '</nav>'
}
