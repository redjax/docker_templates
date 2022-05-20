#!/bin/bash

# Use this script to automatically switch to a branch,
# fetch, and pull

BRANCH=${1}

function CHECKOUT_BRANCH () {
  echo ""
    echo "Switching branch to $1"
    echo ""
    git checkout $BRANCH

    echo ""
    echo "Run git fetch on $BRANCH"
    echo ""
    git fetch

    echo ""
    echo "Run git pull on $BRANCH"
    echo ""
    git pull

    echo ""
    echo "Branch switched successfully."
    echo ""
}

case $1 in
  "")
    echo "Listing branches"
    echo "----------------"
    git branch
  ;;
  *)
    CHECKOUT_BRANCH
  ;;
esac

exit
