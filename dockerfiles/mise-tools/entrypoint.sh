#!/usr/bin/env bash

# Parse flags
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            cat << 'EOF'
mise-tools Container
===================

A development container with mise and various development tools pre-installed.

USAGE:
    docker run [OPTIONS] mise-tools:alpine [COMMAND]

INSTALLED TOOLS:
EOF
            echo ""
            /root/.local/bin/mise list 2>/dev/null | while IFS= read -r line; do
                echo "    $line"
            done
            cat << 'EOF'

ADDITIONAL TOOLS:
    - mise (tool version manager)
    - Neovim with custom configuration
    - Zellij terminal multiplexer

EXAMPLES:
    # Start interactive bash shell
    docker run -it --rm mise-tools:alpine

    # Mount a volume
    docker run -it --rm -v /path/to/code:/workspace mise-tools:alpine

    # Run a specific command
    docker run --rm mise-tools:alpine python --version

    # Check installed tools
    docker run --rm mise-tools:alpine mise list

NOTES:
    - All mise tools are configured globally
    - Working directory is /workspace
    - Neovim and zellij configs are pre-configured

EOF
            exit 0
            ;;
        *)
            # Not a flag, stop parsing and execute as command
            break
            ;;
    esac
    shift
done

# Execute the provided command, or default to bash
exec "${@:-bash}"
