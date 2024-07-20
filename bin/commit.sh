#!/bin/sh
# SPDX-License-Identifier: CC-BY-4.0

# This script updates the “date.updated” key of an item based on the
# system time. (Or, it will, once I’m done with it.)

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
system time. (Or, it will, once I’m done with it.)\n' "$script"
  exit 1
#fi

# todo: find POSIX alternative to GNU date options
epoch="$(date -u '+%-s')"
readonly epoch
export epoch

# "date -d" = "date --date"
year="$(date -ud "$epoch" '+%-Y')"
month="$(date -ud "$epoch" '+%-m')"
day="$(date -ud "$epoch" '+%-d')"
hour="$(date -ud "$epoch" '+%-H')"
minute="$(date -ud "$epoch" '+%-M')"
second="$(date -ud "$epoch" '+%-S')"
readonly year month day hour minute second
export year month day hour minute second

# todo: replace values in “info.json”
