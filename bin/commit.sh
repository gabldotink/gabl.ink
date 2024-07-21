#!/bin/sh
# SPDX-License-Identifier: CC-BY-4.0

# This script updates the “date.updated” key of an item based on the
# system time. (Or, it will, once I’m done with it.)

# activate POSIX mode for Bash
readonly POSIXLY_CORRECT
export POSIXLY_CORRECT

script="$0"
item="$1"
# todo: improve regular expression
item_regex='[a-z][a-z0-9._-]+$'
readonly script item item_regex
export script item item_regex

if ! "$(printf '%s\n' "$item"|grep -E "$item_regex")";then
  printf 'usage: %s <item>

This script updates the “date.updated” key of an item based on the
system time. (Or, it will, once I’m done with it.)\n' "$script"
  exit 1
fi

index="$(dirname "$script")/../index"
# todo: GNU “date” dependency
epoch="$(date -u '+%-s')"
readonly index epoch
export index epoch

set_json(){
  s="$1"
  key="$2"
  export s key

  value="$(date -u --date="@$epoch" "+%-$s")"
  export value

  # todo: “jq” dependency
  # todo: “sponge” dependency
  jq --compact-output --arg key "$key" --argjson value "$value" \
    '.date.updated[$key] = $value' "$index/$item/info.json" \
    |sponge "$index/$item/info.json"
}

set_json Y year
set_json m month
set_json d day
set_json H hour
set_json M minute
set_json S second

jq -c --arg full "$(date -u --date="@$epoch" '+%Y-%m-%dT%H:%M:%S+00:00')" \
  '.date.updated.full = $full' "$index/$item/info.json" \
  |sponge "$index/$item/info.json"
