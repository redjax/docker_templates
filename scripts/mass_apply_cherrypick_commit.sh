#!/bin/bash

COMMIT_HASH=$1

if [ -z "$COMMIT_HASH" ]; then
    echo "Usage: $0 <commit-hash>"
    exit 1
fi

# Array of branches to exclude
EXCLUDED_BRANCHES=("main" "dev" "staging" "release")

# Function to check if a branch is in the excluded list
is_excluded() {
    local branch=$1
    for excluded in "${EXCLUDED_BRANCHES[@]}"; do
        if [[ "$branch" == "$excluded" ]]; then
            return 0
        fi
    done
    return 1
}

# Get the current branch to switch back later
current_branch=$(git branch --show-current)

# Loop through all branches and skip excluded ones
for branch in $(git branch --format='%(refname:short)'); do
    if is_excluded "$branch"; then
        echo "Skipping excluded branch: $branch"
        continue
    fi

    echo "Switching to branch: $branch"
    
    # Check for uncommitted changes and stash if needed
    if ! git diff-index --quiet HEAD --; then
        echo "Stashing uncommitted changes..."
        git stash push -m "auto-stash before cherry-pick"
    fi

    # Checkout the branch
    git checkout "$branch" || continue

    echo "Applying commit to branch: $branch"
    if git cherry-pick "$COMMIT_HASH"; then
        echo "Cherry-pick successful on branch $branch"
        git push origin "$branch"
    else
        echo "Cherry-pick failed on branch $branch. Aborting."
        git cherry-pick --abort
    fi

    # Apply stashed changes if any
    if git stash list | grep -q "auto-stash before cherry-pick"; then
        echo "Restoring stashed changes..."
        git stash pop
    fi

    echo "----------------------------------------"
done

# Switch back to the original branch
git checkout "$current_branch"
echo "Switched back to original branch: $current_branch"
