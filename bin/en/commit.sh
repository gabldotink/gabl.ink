#!/bin/sh
# SPDX-License-Identifier: CC-BY-4.0

# This script updates the “date.updated” key of an item based on the
# system time. (Or, it will, once I’m done with it.)

# activate POSIX mode for Bash
readonly POSIXLY_CORRECT
export POSIXLY_CORRECT

script="$0"
id="$1"
# todo: improve regular expression
id_regex='[a-z][a-z0-9_-]+$'
export script id item_regex
readonly script item_regex

if "$(printf '%s\n' "$id"|grep -Eve "$id_regex">/dev/null)";then
  # shellcheck disable=SC1112
  printf 'usage: %s <item>

This script updates the “date.updated” key of an item based on the
system time. (Or, it will, once I’m done with it.)\n' "$script"
  exit 1
fi

items="$id"
export items

until [ "$(dirname "$id")" = index ];do
  id="$(dirname "$id")"
  items="$items $id"
done
readonly items

epoch="$(date -u '+%s')"
# todo: “readlink” dependency
index="$(readlink --canonicalize "$(dirname "$script")/../../index")"
export epoch index
wait
readonly epoch index

set_json(){
  s="$1"
  key="$2"
  export s key

  # todo: GNU “date” dependency
  value="$(date -u --date="@$epoch" "+%-$s")"
  export value

  # todo: “jq” dependency
  # todo: “sponge” dependency
  jq --compact-output --arg key "$key" --argjson value "$value" \
    '.date.updated[$key] = $value' "$output" \
    |sponge "$output">/dev/null
}

for item in $items;do
  output="$index/$item/info.json"
  export output

  set_json Y year
  set_json m month
  set_json d day
  set_json H hour
  set_json M minute
  set_json S second

  jq --compact-output --arg full \
    "$(date -u --date="@$epoch" '+%Y-%m-%dT%H:%M:%S+00:00')" \
    '.date.updated.full = $full' "$output" \
    |sponge "$info_json">/dev/null
done
