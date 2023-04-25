#!/bin/bash
echo "update src file"
git pull
git add .
git commit -m "new commit: $1 `date`"
git push
echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the project.
hugo -D # if using a theme, replace with `hugo -t <YOURTHEME>`

# Go To Public folder
cd public

# Add changes to git.
git add .

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push 

# Come Back up to the Project Root
cd ..
