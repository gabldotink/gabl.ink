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
# “jq -r” = “jq --raw-output”
year="$(jq -r .date.updated.year \
              "$bin_dir/../index/$item/info.json")"
export year

month="$(jq -r .date.updated.month \
               "$bin_dir/../index/$item/info.json")"
export month

day="$(jq -r .date.updated.day \
             "$bin_dir/../index/$item/info.json")"
export day

hour="$(jq -r .date.updated.hour \
              "$bin_dir/../index/$item/info.json")"
export hour

minute="$(jq -r .date.updated.minute \
                "$bin_dir/../index/$item/info.json")"
export minute

second="$(jq -r .date.updated.second \
                "$bin_dir/../index/$item/info.json")"
export second

# todo: find POSIX alternative to “date -r”
# todo: cache “date” outputs instead of running multiple times
# todo: use parallel processes for “date”
# todo: strip leading zeros
# todo: do “test && year= ; export year”?
# “date -ur” = “date --utc --reference”
for i in "$bin_dir/../index/$item/"*;do
  export i
  if [ "$(date -ur "$i" '+%Y')" -gt "$year" ];then
    year="$(date -ur "$i" '+%Y')"
    export year
  fi
  if [ "$(date -ur "$i" '+%m')" -gt "$month" ];then
    month="$(date -ur "$i" '+%m')"
    export month
  fi
  if [ "$(date -ur "$i" '+%d')" -gt "$day" ];then
    day="$(date -ur "$i" '+%d')"
    export day
  fi
  if [ "$(date -ur "$i" '+%H')" -gt "$hour" ];then
    hour="$(date -ur "$i" '+%d')"
    export hour
  fi
  if [ "$(date -ur "$i" '+%M')" -gt "$minute" ];then
    minute="$(date -ur "$i" '+%d')"
    export minute
  fi
  if [ "$(date -ur "$i" '+%S')" -gt "$second" ];then
    second="$(date -ur "$i" '+%S')"
    export second
  fi
done

# todo: replace values in “info.json”
