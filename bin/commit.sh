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

index="$(dirname "$script")/../index"
readonly index
export index

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
  readonly s key
  export s key

  # “date -d” = “date --date”
  value="$(date -ud "@$epoch" "+%-$s")"
  readonly value
  export value

  # todo: “jq” dependency
  # todo: “sponge” dependency
  jq --arg key "$key" --arg value "$value" \
    '.date.updated.$key = $value' "$index/$item/info.json" \
   |sponge "$index/$item/info.json"
}

set_json Y year
set_json m month
set_json d day
set_json H hour
set_json M minute
set_json S second
