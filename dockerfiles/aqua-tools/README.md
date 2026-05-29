# Aqua Tools Container

Alpine-based container with [Aqua](https://aquaproj.github.io/) for declarative CLI tool management.

## Quick Start

```powershell
# Build with defaults (latest versions)
.\build.ps1

# Build with specific versions
.\build.ps1 -AquaInstallerVersion v4.0.4 -AquaVersion v2.55.3

# Build with custom tag
.\build.ps1 -Tag mytools:latest
```

## Usage

```bash
# Run interactively
docker run -it --rm aqua-tools:alpine

# Run with workspace mounted
docker run -it --rm -v ${PWD}:/workspace aqua-tools:alpine

# Execute specific command
docker run --rm aqua-tools:alpine python --version
```

## Installed Tools

Tools are defined in `aqua.yaml` and installed globally. Check the file for the complete list.

## GitHub Token

To avoid rate limits, create a `github_token.txt` file with your GitHub personal access token:

```powershell
echo "ghp_your_token_here" > github_token.txt
```

The token is mounted as a Docker secret and never stored in the image.

## Configuration

- Aqua config: `aqua.yaml`
- User configs: `config/` directory (zellij, neovim, etc.)
- Global install: Tools available everywhere via `AQUA_GLOBAL_CONFIG`

## Build Arguments

- `AQUA_INSTALLER_VERSION`: Version of aqua-installer to use (default: v4.0.4)
- `AQUA_VERSION`: Version of aqua CLI to install (default: v2.55.3)
