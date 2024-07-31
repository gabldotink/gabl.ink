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
id_regex='[a-z][a-z0-9-]+$'
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
index="$(readlink --canonicalize "$(dirname "$script")/../../../..")"
export epoch index
readonly epoch index

write_json(){
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
export write_json
readonly write_json

for item in $items;do
  output="$index/$item/info.json"
  export output

  write_json Y year
  write_json m month
  write_json d day
  write_json H hour
  write_json M minute
  write_json S second

  jq --compact-output --arg full \
    "$(date -u --date="@$epoch" '+%Y-%m-%dT%H:%M:%S+00:00')" \
    '.date.updated.full = $full' "$output" \
    |sponge "$info_json">/dev/null
done
