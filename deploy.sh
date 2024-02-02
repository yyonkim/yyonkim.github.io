#!/bin/bash

# update submodules (study-logs repos)
git add .


# Commit changes.

msg="rebuilding site `date`"

if [ $# -eq 1 ]

then msg="$1"

fi

git commit -m "$msg"

  

# Push source and build repos.

git push origin main
