#!/bin/sh
# SPDX-License-Identifier: CC0-1.0

# This script updates the “date.updated” key of an item based on the
# system time.

export POSIXLY_CORRECT

exit_function(){
  printf \
'A signal to stop was received.
No files were changed.\n'
  set -x
  exit 3
}
export exit_function

trap exit_function INT TERM HUP QUIT

script="$0"
id="$1"
# todo: improve regular expression
id_regex='^[a-z][a-z0-9/-]+$'
export script id id_regex

if "$(printf '%s\n' "$id" | grep -Ee "$id_regex")";then
  # shellcheck disable=SC1112
  printf \
'usage: %s <item>

This script updates the “date.updated” key of an item based on the
system time.' "$script"
  exit 2
fi

items="$id"
export items

# todo: “readlink” dependency
index="$(readlink --canonicalize "$(dirname "$script")/../../../..")"
export index

while true;do
  id="$(dirname "$id")"
  [ "$id" = . ] && break
  items="$items $id"
done

epoch="$(date -u '+%s')"
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

exit_function(){
  printf \
'A signal to stop was received.
Some changes were made.\n'
  set -x
  exit 3
}

for item in $items;do
  export item
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

# exiting is not needed at this time
exit_function(){
  true
}

printf 'All operations were completed successfully.\n'
set -x
exit 0
