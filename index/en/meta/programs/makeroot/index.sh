#!/bin/sh
# SPDX-License-Identifier: CC0-1.0

script="$0"
readonly script
export script

# todo: “readlink” dependency
root="$(readlink --canonicalize "$(dirname "$script")/../../../../..")"
readonly root
export root

index="$root/index"
readonly index
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
