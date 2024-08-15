#!/bin/sh
# SPDX-License-Identifier: CC0-1.0

# This script interactively creates an item the user asks for.

# ========== work in progress! ==========

export POSIXLY_CORRECT

exit_function(){
  printf \
'A signal to stop was received.
No files were changed.\n'
  set -x
  exit 3
}
export exit_function

trap exit_function INT TERM HUP QUIT

script="$0"
id="$1"
# todo: improve regular expression
id_regex='^[a-z][a-z0-9/-]+$'
export script id id_regex

if "$(printf '%s\n' "$id" | grep -Ee "$id_regex")";then
  printf \
'usage: %s <item>

This script interactively creates an item the user asks for.\n' \
                                                        "$script"
  exit 2
fi

printf 'You are creating item “%s”; is that what you want? [y/n]\n' \
                                                                "$id"
read -r confirmation

index="$script/../../../.."
export index

item="$index/$id"
export item

if [ "$confirmation" = y ];then
  if ! [ -f "$item/.." ];then
    printf \
    'The parent item does not exist. Please create that first.\n'
    set -x
    exit 1
  fi
  exit_function(){
    printf \
'A signal to stop was received.
Some files were changed.\n
    set -x
    exit 3
  }
  mkdir -p "$item"
  printf '{}\n' > "$index/$id/info.json"
fi
