#!/bin/sh
# SPDX-License-Identifier: CC0-1.0
# ================= wrap lines at 72 printed characters ================

export POSIXLY_CORRECT

script="$0"
export script

root="$(dirname "$script")/../../../../.."
export root

index="$root/index"
export index

cp -fp   "$index/en/meta/htaccess/index.htaccess" \
         "$root/.htaccess"
cp -fp   "$index/en/meta/robots/index.txt" \
         "$root/robots.txt"
cp -fp   "$index/en/meta/git/attributes/index.gitattributes" \
         "$root/.gitattributes"
cp -fp   "$index/mul/meta/root/index.html" \
         "$root/index.html"
cp -fp   "$index/en/meta/github/readme/index.md" \
         "$root/readme.md"
mkdir -p "$root/.github"
cp -fp   "$index/en/meta/github/settings/index.yml" \
         "$root/.github/settings.yml"

printf 'All operations were completed successfully.\n'
set -x
exit 0
