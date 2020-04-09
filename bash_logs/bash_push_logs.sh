#!/bin/bash

## seth path
parent_path=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$parent_path"

## Run R
git_mess="Automatic update bash logs, $(date +'%d %b %Y')"
git commit runR_commitGit* -m "$git_mess"
git push origin master
echo "Done, $(date +'%d %b %Y at %H:%M')"

