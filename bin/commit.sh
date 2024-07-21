#!/bin/sh
# SPDX-License-Identifier: CC-BY-4.0

# This script updates the “date.updated” key of an item based on the
# system time. (Or, it will, once I’m done with it.)

# activate POSIX mode for Bash
readonly POSIXLY_CORRECT
export POSIXLY_CORRECT

script="$0"
item="$1"
index="$(dirname "$script")/../index"
readonly script item index
export script item index

# todo: implement validation
#item_regex='^[A-Za-z0-9._-]+$'
#readonly item_regex
#export item_regex

#if ! "$(printf '%s\n' "$item"|grep -E "$item_regex")";then
#  printf 'usage: %s <item>
#
#This script updates the “date.updated” key of an item based on the
#system time. (Or, it will, once I’m done with it.)\n' "$script"
#  exit 1
#fi

# todo: GNU “date” dependency
epoch="$(date -u '+%-s')"
readonly epoch
export epoch

set_json(){
  s="$1"
  key="$2"
  export s key

  # “date -d” = “date --date”
  value="$(date -ud "@$epoch" "+%-$s")"
  export value

  # todo: “jq” dependency
  # todo: “sponge” dependency
  # “jq -c” = “jq --compact-output”
  jq -c --arg key "$key" --argjson value "$value" \
    '.date.updated[$key] = $value' "$index/$item/info.json" \
    |sponge "$index/$item/info.json"
}

set_json Y year
set_json m month
set_json d day
set_json H hour
set_json M minute
set_json S second

jq -c --arg full "$(date -ud "@$epoch" '+%Y-%m-%dT%H:%M:%S+00:00')" \
  '.date.updated.full = $full' "$index/$item/info.json" \
  |sponge "$index/$item/info.json"
