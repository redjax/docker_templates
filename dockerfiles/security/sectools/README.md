# Security Scanning Tools Container <!-- omit in toc -->

A multi-tool Docker image containing popular security scanners:

- [Gitleaks](https://github.com/gitleaks/gitleaks) - Detect secrets in code
- [TruffleHog](https://github.com/trufflesecurity/trufflehog) - Find leaked credentials
- [OSV Scanner](https://github.com/google/osv-scanner) - Scan for known vulnerabilities in dependencies

## Table of Contents <!-- omit in toc -->

- [Quick Start](#quick-start)
- [Usage](#usage)
  - [Using the wrapper script (easiest)](#using-the-wrapper-script-easiest)
  - [Using Docker Compose](#using-docker-compose)
  - [Using tools directly](#using-tools-directly)
- [Environment Variables](#environment-variables)
- [Volume Mounts](#volume-mounts)
- [Build Arguments](#build-arguments)
- [Output](#output)
- [Examples](#examples)
- [Tips](#tips)

## Quick Start

Build the image:

```bash
docker build -t sectools .
```

## Usage

### Using the wrapper script (easiest)

Scan with Gitleaks:

```bash
docker run --rm \
  -v $(pwd):/scan \
  -v $(pwd)/results:/results \
  -e TOOL=gitleaks \
  sectools
```

Scan with TruffleHog:

```bash
docker run --rm \
  -v $(pwd):/scan \
  -v $(pwd)/results:/results \
  -e TOOL=trufflehog \
  sectools
```

Scan with OSV Scanner:

```bash
docker run --rm \
  -v $(pwd):/scan \
  -v $(pwd)/results:/results \
  -e TOOL=osv-scanner \
  sectools
```

### Using Docker Compose

The compose file supports environment variables for flexible configuration:
- `SCAN_TARGET_PATH` - Directory to scan (default: `./`)
- `SCAN_RESULTS_DIR` - Where to save results (default: `./results`)

```bash
## Run all tools at once
docker compose up

## Run sequentially
docker compose run gitleaks
docker compose run trufflehog
docker compose run osv-scanner

## Run specific tools in parallel
docker compose up gitleaks trufflehog

## Override scan path
SCAN_TARGET_PATH=/path/to/code docker compose run gitleaks

## Or with a loop
for tool in gitleaks trufflehog osv-scanner; do
  docker compose run $tool
done
```

### Using tools directly

You can also call the tools directly with custom options:

```bash
## Gitleaks with custom options
docker run --rm -v $(pwd):/scan sectools \
  gitleaks detect --source=/scan --verbose

## TruffleHog scanning a git repo
docker run --rm -v $(pwd):/scan sectools \
  trufflehog git file:///scan --json

## OSV Scanner with specific lockfile
docker run --rm -v $(pwd):/scan sectools \
  osv-scanner scan --lockfile=/scan/package-lock.json
```

## Environment Variables

- `TOOL` - Which tool to run (gitleaks, trufflehog, osv-scanner). Default: gitleaks
- `SCAN_PATH` - Path inside container to scan. Default: /scan
- `RESULTS_PATH` - Path to save results. Default: /results

## Volume Mounts

- `/scan` - Mount your code directory here
- `/results` - Mount to persist scan results

## Build Arguments

You can customize tool versions during build:

```bash
docker build \
  --build-arg GITLEAKS_VERSION=8.18.4 \
  --build-arg TRUFFLEHOG_VERSION=3.82.13 \
  --build-arg OSV_VERSION=1.9.1 \
  -t sectools .
```

## Output

Results are saved in JSON format:
- Gitleaks: `/results/gitleaks-report.json`
- TruffleHog: `/results/trufflehog-report.json`
- OSV Scanner: `/results/osv-report.json`

## Examples

Scan current directory with all tools:

```bash
## Create results directory
mkdir -p results

## Run each scanner
for tool in gitleaks trufflehog osv-scanner; do
  echo "Running $tool..."
  docker run --rm \
    -v $(pwd):/scan \
    -v $(pwd)/results:/results \
    -e TOOL=$tool \
    sectools
done
```

## Tips

- The `|| true` in the wrapper script prevents the container from exiting with error codes when findings are detected
- Results persist in the mounted `/results` directory
- All tools can also be run interactively: `docker run -it --rm -v $(pwd):/scan sectools bash`
