# shellcheck shell=sh
# SPDX-License-Identifier: CC0-1.0

# TODO: Reduce duplicate code.
# TODO: Handle multiple chapters.
# TODO: Handle quotation marks in other page titles.

make_nav_f_l(){
  if   [ "$1" = f ];then
    make_nav_f_l_a=⇦
    make_nav_f_l_i=first
    make_nav_f_l_u="$(printf_l10n nav_button_first)"
    make_nav_f_l_z=prev
  elif [ "$1" = l ];then
    make_nav_f_l_a=⇨
    make_nav_f_l_i=last
    make_nav_f_l_u="$(printf_l10n nav_button_last)"
    make_nav_f_l_z=next
  else
    err e 'make_nav_f_l direction is not f or l'
  fi

  printf -- '<div class=nav_button id=nav_%s_buttons_%s ' "$make_nav_l" "$make_nav_f_l_i"

  if [ "$(eval 'printf %s "$'"$make_nav_f_l_z"'"')" = null ];then
    printf -- 'title=%s>' "$(printf_l10n this_is_x_page "$(printf_l10n "nav_button_${make_nav_f_l_i}_inline")")"
  else
    printf -- 'title="%s">' "$(printf_l10n nav_button_page_title "$(eval 'printf %s "$container_'"$make_nav_f_l_i"'_title_text"')")"
    printf -- '<a href=../../%s/%s/ hreflang=%s type=text/html>' "$(eval 'printf %d "$container_'"$make_nav_f_l_i"'"')" "$lang_i" "$lang"
  fi

  printf -- '<p><span class=nav_button_arrow aria-hidden=true>%s</span><br>%s</p>' "$make_nav_f_l_a" "$make_nav_f_l_u"

  [ "$(eval 'printf -- %s "$'"$make_nav_f_l_z"'"')" = null ] ||
    printf '</a>'

  printf '</div>'
}

make_nav_p_n(){
  if   [ "$1" = p ];then
    make_nav_p_n_a=←
    make_nav_p_n_i=prev
    make_nav_p_n_u="$(printf_l10n nav_button_prev)"
    make_nav_p_n_z=first
  elif [ "$1" = n ];then
    make_nav_p_n_a=→
    make_nav_p_n_i=next
    make_nav_p_n_u="$(printf_l10n nav_button_next)"
    make_nav_p_n_z=last
  else
    err e 'make_nav_p_n direction is not p or n'
  fi

  printf -- '<div class=nav_button id=nav_%s_buttons_%s ' "$make_nav_l" "$make_nav_p_n_i"

  if [ "$(eval 'printf -- %s "$'"$make_nav_p_n_i"'"')" = null ];then
    printf -- 'title=%s>' "$(printf_l10n this_is_x_page "$(printf_l10n "nav_button_${make_nav_p_n_z}_inline")")"
  else
    printf -- 'title="%s">' "$(printf_l10n nav_button_page_title "$(eval 'printf %s "$'"$make_nav_p_n_i"'_title_text"')")"
    printf -- '<a href=../../%s/%s/ rel=%s hreflang=%s type=text/html>' "$(eval 'printf %d "$'"$make_nav_p_n_i"'"')" "$lang_i" "$make_nav_p_n_i" "$lang"
  fi

  printf -- '<p><span class=nav_button_arrow aria-hidden=true>%s</span><br>%s</p>' "$make_nav_p_n_a" "$make_nav_p_n_u"

  [ "$(eval 'printf -- %s "$'"$make_nav_p_n_i"'"')" = null ] ||
    printf '</a>'

  printf '</div>'
}

make_nav(){
  make_nav_l="$1"

  printf '<nav id=nav_%s_buttons>' "$make_nav_l"

  make_nav_f_l f
  make_nav_p_n p
  make_nav_p_n n
  make_nav_f_l l

  printf '</nav>'
}
