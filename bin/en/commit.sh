#!/bin/sh
# SPDX-License-Identifier: CC-BY-4.0

# This script updates the “date.updated” key of an item based on the
# system time. (Or, it will, once I’m done with it.)

# activate POSIX mode for Bash
readonly POSIXLY_CORRECT
export POSIXLY_CORRECT

script="$0"
items="$1"
# todo: improve regular expression
item_regex='[a-z][a-z0-9_-]+$'
readonly script item_regex
export script items item_regex

if "$(printf '%s\n' "$item"|grep -Eve "$item_regex">/dev/null)";then
  # shellcheck disable=SC1112
  printf 'usage: %s <item>

This script updates the “date.updated” key of an item based on the
system time. (Or, it will, once I’m done with it.)\n' "$script"
  exit 1
fi

until [ "$(dirname "$items")" = index ];do
  items="$items $(dirname "$items")"
  export items
done

readonly items
export items

# todo: “readlink” dependency
index="$(readlink --canonicalize "$(dirname "$script")/../../index")"
readonly index
export index

for item in $items;do
  export item
  info_json="$index/$item/info.json"
  # todo: GNU “date” dependency
  epoch="$(date -u '+%-s')"

  set_json(){
    s="$1"
    key="$2"
    export s key

    value="$(date -u --date="@$epoch" "+%-$s")"
    export value

    # todo: “jq” dependency
    # todo: “sponge” dependency
    jq --compact-output --arg key "$key" --argjson value "$value" \
      '.date.updated[$key] = $value' "$info_json" \
      |sponge "$info_json">/dev/null
  }

  set_json Y year
  set_json m month
  set_json d day
  set_json H hour
  set_json M minute
  set_json S second

  jq --compact-output --arg full \
    "$(date -u --date="@$epoch" '+%Y-%m-%dT%H:%M:%S+00:00')" \
    '.date.updated.full = $full' "$info_json" \
    |sponge "$info_json">/dev/null
done
