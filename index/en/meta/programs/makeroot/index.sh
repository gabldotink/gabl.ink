#!/bin/sh
# SPDX-License-Identifier: CC0-1.0

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
export script

# todo: “readlink” dependency
root="$(readlink --canonicalize "$(dirname "$script")/../../../../..")"
export root

index="$root/index"
export index

exit_function(){
  printf \
'A signal to stop was received.
Some files were changed.\n'
  set -x
  exit 3
}

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

# exiting is not needed at this time
exit_function(){
  true
}

printf 'All operations were completed successfully.\n'
set -x
exit 0
