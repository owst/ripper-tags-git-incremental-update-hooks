#!/usr/bin/env bash

set -euo pipefail

tmpdir=$(mktemp -d)
trap "rm -rf $tmpdir" EXIT

changed_files_file="$tmpdir/changed_files.txt"

# Ignore deleted files
git diff --name-only --diff-filter=d $1 $2 '*.rb' > "$changed_files_file"
change_count=$(wc -l "$changed_files_file" | cut -d ' ' -f1)

if (( $change_count > 0 )); then
    echo "Updating tags using ripper-tags between $1 and $2" \
        "($change_count files)"

    xargs --arg-file "$changed_files_file" ripper-tags --tag-file new_tags

    # If a non-empty tags file exists, we need to merge the old and new tags.
    if [ -s tags ]; then
        # Based on https://goo.gl/JFHEGX
        {
            # Remove the old tags for the updated files
            cat tags | grep -v -f "$changed_files_file"
            # Remove the tags header of the new_tags file
            cat new_tags | grep -v '^!_'
        } | sort > merged_tags

        mv {merged,new}_tags
    fi

    mv {new_,}tags
fi
