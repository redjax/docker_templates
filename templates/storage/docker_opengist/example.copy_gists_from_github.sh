#!/bin/bash

## Instructions
#  Copy this file to copy_gists_from_github.sh.
#  Modify the github_user and opengist_url with your own data.
#  Make the script executable with chmod +x copy_gists_from_github.sh
#
#  DELETE THESE INSTRUCTIONS AFTER COPYING.

github_user=user
## Replace user, password and Opengist url
opengist_url="http://user:password@opengist.url/init"

curl -s https://api.github.com/users/"$github_user"/gists?per_page=100 | jq '.[] | .git_pull_url' -r | while read url; do
    git clone "$url"
    repo_dir=$(basename "$url" .git)

    # Add remote, push, and remove the directory
    if [ -d "$repo_dir" ]; then
        cd "$repo_dir"
        git remote add gist "$opengist_url"
        git push -u gist --all
        cd ..
        rm -rf "$repo_dir"
    fi
done
