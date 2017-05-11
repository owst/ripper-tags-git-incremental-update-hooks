#!/usr/bin/env bash

set -euo pipefail

tmpdir=$(mktemp -d)
trap "rm -rf $tmpdir" EXIT

changed_files_file="$tmpdir/changed_files.txt"

git diff --name-only $1 $2 | grep '\.rb$' > $changed_files_file

change_count=$(wc -l "$changed_files_file" | cut -d ' ' -f1)

if (( $change_count > 0 )); then
    echo "Updating tags using ripper-tags between $1 and $2" \
        "($change_count files)"

    # Based on https://goo.gl/JFHEGX
    {
        cat tags | grep -v -f $changed_files_file
        xargs --arg-file $changed_files_file ripper-tags --tag-file - | \
            grep -v '^!_' # remove header in new tags file
    } | sort > new_tags

    mv {new_,}tags
fi
