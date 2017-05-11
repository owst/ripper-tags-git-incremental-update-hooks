#!/usr/bin/env bash

set -euo pipefail

for hook in hooks/*
do
    target_dir="$1/.git/hooks/"

    if ln -s `pwd`/$hook "$target_dir" 2>/dev/null
    then
        echo "Successfully linked $hook into $target_dir"
    else
        echo "Failed to link $hook into $target_dir"
    fi
done
