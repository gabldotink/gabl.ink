# shellcheck shell=sh
# shellcheck disable=2154
# SPDX-License-Identifier: CC0-1.0

make_og(){
  printf '<meta property="og:%s" content="%s"/>' "$1" "$2"
}
