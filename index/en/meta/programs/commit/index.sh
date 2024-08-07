#!/bin/sh
# SPDX-License-Identifier: CC-BY-4.0

# This script updates the “date.updated” key of an item based on the
# system time.

readonly POSIXLY_CORRECT
export POSIXLY_CORRECT

script="$0"
id="$1"
# todo: improve regular expression
id_regex='^[a-z][a-z0-9-]+$'
readonly script id_regex
export script id id_regex

if "$(printf '%s\n' "$id" | grep -Ee "$id_regex")";then
  # shellcheck disable=SC1112
  printf 'usage: %s <item>

This script updates the “date.updated” key of an item based on the
system time.' "$script"
  exit 1
fi

items="$id"
export items

# todo: “readlink” dependency
index="$(readlink --canonicalize "$(dirname "$script")/../../../..")"
readonly index
export index

while true;do
  id="$(dirname "$id")"
  [ "$id" = . ] && break
  items="$items $id"
done
readonly items

epoch="$(date -u '+%s')"
readonly epoch
export epoch

write_json(){
  s="$1"
  key="$2"
  export s key

  # todo: GNU “date” dependency
  value="$(date -u --date="@$epoch" "+%-$s")"
  export value

  printf '%s\n' "$(
    # todo: “jq” dependency
    jq --compact-output --arg key "$key" --argjson value "$value" \
      '.date.updated[$key] = $value' "$output"
  )" > "$output"
}
export write_json
readonly write_json

for item in $items;do
  output="$index/$item/info.json"
  export output

  printf '%s\n' "$(
    jq --compact-output --argjson epoch "$epoch" \
      '.date.updated.epoch = $epoch' "$output" \
  )" > "$output"

  write_json Y year
  write_json m month
  write_json d day
  write_json H hour
  write_json M minute
  write_json S second

  printf '%s\n' "$(
    jq --compact-output --arg full \
      "$(date -u --date="@$epoch" '+%Y-%m-%dT%H:%M:%S+00:00')" \
      '.date.updated.full = $full' "$output" \
  )" > "$output"
done

exit 0