# shellcheck shell=sh
# shellcheck disable=SC2154
# SPDX-License-Identifier: CC0-1.0
# Do not run or source this file! It is meant to be sourced by ../build.sh only.

make_og() {
  make_og_property="$1"
  make_og_content="$2"
  
  printf '<meta property="og:%s" content="%s"/>' "${make_og_property}" "${make_og_content}"
}
