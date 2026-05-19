#!/usr/bin/env bash
set -e

echo "Setting all installed tools globally"

## Get list of all installed tools and set them globally
#  Use process substitution instead of pipe to avoid subshell issues
while IFS= read -r line; do
    ## Extract tool name and version from mise ls output
    tool=$(echo "$line" | awk '{print $1}')
    version=$(echo "$line" | awk '{print $2}')
    
    if [ -n "$tool" ] && [ -n "$version" ]; then
        echo "Setting $tool@$version globally"
        /root/.local/bin/mise use -g "$tool@$version" || echo "Warning: Failed to set $tool@$version"
    fi
done < <(/root/.local/bin/mise ls --installed 2>/dev/null | tail -n +2)

echo "Global configuration set successfully"
