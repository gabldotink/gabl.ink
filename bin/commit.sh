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

# this regular expression will work later
item_regex='^[A-Za-z0-9._-]+$'
readonly item_regex
export item_regex

#if ! $(printf '%s' "$item"|grep -E "$item_regex");then
  printf 'usage: %s <item>

This script updates the “date.updated” key of an item based on file
modification times. (Or, it will, once I’m done with it.)\n' "$script"
#fi
