#!/bin/bash

arg="$1"

path="${arg%%||*}"
profile="${arg#*||}"

if [ "$profile" = "Default" ]; then
    code "$path"
else
    code --profile "$profile" "$path"
fi
