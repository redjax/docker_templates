#!/usr/bin/env bash
set -euo pipefail

## Install Python tools using uv tool install
#  This installs each tool in an isolated environment while making them globally available

echo "Installing Python-based CLI tools with uv"

## Install Azure CLI in a virtual environment
echo "Installing Azure CLI in virtual environment"
python3 -m venv /opt/az

/opt/az/bin/pip install --upgrade pip
/opt/az/bin/pip install azure-cli

ln -s /opt/az/bin/az /usr/local/bin/az

## Install yamllint
echo "Installing yamllint"
uv tool install yamllint

## Install pre-commit for git hooks
echo "Installing pre-commit"
uv tool install pre-commit

echo ""
echo "Python tools installation complete!"
echo ""
echo "Installed tools:"
uv tool list
