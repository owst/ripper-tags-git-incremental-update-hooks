#!/usr/bin/env bash

set -euo pipefail

changed_files_file=$(mktemp 'changed_files.txt')
trap "rm -f $changed_files_file" EXIT

git diff --name-only $1 $2 | grep '\.rb$' > $changed_files_file

change_count=$(wc -l $changed_files_file)

if [ $change_count -gt 0 ]; then
    echo "Updating tags using ripper-tags between $1 and $2" \
        "($change_count .rb files)"

    # Based on https://goo.gl/JFHEGX
    {
        cat tags | grep -v -f $changed_files_file
        xargs --arg-file $changed_files_file ripper-tags --tag-file - | \
            grep -v '^!_' # remove header in new tags file
    } | sort > new_tags

    mv {new_,}tags
fi
