#!/bin/bash

# Use this script to automatically switch to a branch,
# fetch, and pull

BRANCH=${1:-"master"}

echo ""
echo "Switching branch to $BRANCH"
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

exit
