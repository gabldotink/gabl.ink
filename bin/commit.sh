#!/bin/sh
# SPDX-License-Identifier: CC-BY-4.0

# This script updates the “date.updated” key of an item based on file
# modification times. (Or, it will, once I’m done with it.)

# activate POSIX mode for Bash
readonly POSIXLY_CORRECT
export POSIXLY_CORRECT

script="$0"
readonly script
export script

item="$1"
readonly item
export item

bin_dir="$(dirname "$script")"
readonly bin_dir
export bin_dir

# todo: make regular expression actually work for validation
item_regex='^[A-Za-z0-9._-]+$'
readonly item_regex
export item_regex

#if ! "$(printf '%s' "$item"|grep -E "$item_regex")";then
  printf 'usage: %s <item>

This script updates the “date.updated” key of an item based on file
modification times. (Or, it will, once I’m done with it.)\n' "$script"
  exit 1
#fi

# todo: find POSIX alternative to “jq” if possible
# todo: use parallel processes for “jq”
year="$(jq --raw-output .date.updated.year \
            "$bin_dir/../index/$item/info.json")"
export year

month="$(jq --raw-output .date.updated.month \
             "$bin_dir/../index/$item/info.json")"
export month

day="$(jq --raw-output .date.updated.day \
           "$bin_dir/../index/$item/info.json")"
export day

# todo: find POSIX alternative to “date -r”
# todo: cache “date” outputs instead of running multiple times
# todo: use parallel processes for “date”
# todo: strip leading zeros
# todo: do “test && year= ; export year” ?
for i in "$bin_dir/../index/$item/"*;do
  export i
  if [ "$(date -r "$i" '+%Y')" > "$year" ];then
    year="$(date -r "$i" '+%Y')"
    export year
  fi
  if [ "$(date -r "$i" '+%m')" > "$month" ];then
    month="$(date -r "$i" '+%m')"
    export month
  fi
  if [ "$(date -r "$i" '+%d')" > "$day" ];then
    day="$(date -r "$i" '+%d')"
    export day
  fi
done

# todo: have script replace values in “info.json”
