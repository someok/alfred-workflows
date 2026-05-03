#!/bin/bash

rm -f ../VSCode-Recent-Workspaces.alfredworkflow \
    && cd src \
    && zip -r ../../VSCode-Recent-Workspaces.alfredworkflow * -x "*.DS_Store"
