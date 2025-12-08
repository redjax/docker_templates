## Build-time version arguments (override with --build-arg)
ARG ALPINE_VERSION=3.19
ARG GITLEAKS_VERSION=8.18.4
ARG TRUFFLEHOG_VERSION=3.82.13
ARG OSV_VERSION=1.9.1

## Base image with common dependencies
FROM alpine:${ALPINE_VERSION} as base

RUN apk add --no-cache \
    ca-certificates \
    git \
    curl \
    bash

## Install gitleaks
FROM base as gitleaks-installer
ARG GITLEAKS_VERSION
RUN curl -sSfL https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz \
    | tar -xz -C /usr/local/bin gitleaks && \
    chmod +x /usr/local/bin/gitleaks

## Install trufflehog
FROM base as trufflehog-installer
ARG TRUFFLEHOG_VERSION
RUN curl -sSfL https://github.com/trufflesecurity/trufflehog/releases/download/v${TRUFFLEHOG_VERSION}/trufflehog_${TRUFFLEHOG_VERSION}_linux_amd64.tar.gz \
    | tar -xz -C /usr/local/bin trufflehog && \
    chmod +x /usr/local/bin/trufflehog

## Install osv-scanner
FROM base as osv-installer
ARG OSV_VERSION
RUN curl -sSfL https://github.com/google/osv-scanner/releases/download/v${OSV_VERSION}/osv-scanner_${OSV_VERSION}_linux_amd64 \
    -o /usr/local/bin/osv-scanner && \
    chmod +x /usr/local/bin/osv-scanner

## Final image with all tools
FROM base

## Copy all tools from their respective build stages
COPY --from=gitleaks-installer /usr/local/bin/gitleaks /usr/local/bin/
COPY --from=trufflehog-installer /usr/local/bin/trufflehog /usr/local/bin/
COPY --from=osv-installer /usr/local/bin/osv-scanner /usr/local/bin/

## Create directories for scanning and results
RUN mkdir -p /scan /results && \
    chmod 777 /results

WORKDIR /scan

## Create a wrapper script for easier tool selection
COPY --chmod=755 <<'EOF' /usr/local/bin/scan
#!/bin/bash
set -e

TOOL=${TOOL:-gitleaks}
SCAN_PATH=${SCAN_PATH:-/scan}
RESULTS_PATH=${RESULTS_PATH:-/results}

case "$TOOL" in
    gitleaks)
        echo "Running Gitleaks scan..."
        gitleaks detect \
            --source="${SCAN_PATH}" \
            --report-path="${RESULTS_PATH}/gitleaks-report.json" \
            --report-format=json \
            --verbose \
            --no-git || true
        echo "Results saved to ${RESULTS_PATH}/gitleaks-report.json"
        ;;
    trufflehog)
        echo "Running TruffleHog scan..."
        trufflehog filesystem "${SCAN_PATH}" \
            --json \
            --no-update > "${RESULTS_PATH}/trufflehog-report.json" || true
        echo "Results saved to ${RESULTS_PATH}/trufflehog-report.json"
        ;;
    osv-scanner)
        echo "Running OSV Scanner..."
        osv-scanner scan \
            --lockfile="${SCAN_PATH}" \
            --format=json \
            --output="${RESULTS_PATH}/osv-report.json" || true
        echo "Results saved to ${RESULTS_PATH}/osv-report.json"
        ;;
    *)
        echo "Unknown tool: $TOOL"
        echo "Available tools: gitleaks, trufflehog, osv-scanner"
        echo ""
        echo "Usage examples:"
        echo "  docker run -v \$(pwd):/scan -v \$(pwd)/results:/results -e TOOL=gitleaks sectools"
        echo "  docker run -v \$(pwd):/scan -v \$(pwd)/results:/results -e TOOL=trufflehog sectools"
        echo "  docker run -v \$(pwd):/scan -v \$(pwd)/results:/results -e TOOL=osv-scanner sectools"
        echo ""
        echo "Or run tools directly:"
        echo "  docker run -v \$(pwd):/scan sectools gitleaks detect --source=/scan"
        exit 1
        ;;
esac
EOF

## Set the wrapper as the default entrypoint
ENTRYPOINT ["/usr/local/bin/scan"]

## Labels
LABEL org.opencontainers.image.title="Security Scanning Tools" \
      org.opencontainers.image.description="Container with gitleaks, trufflehog, and osv-scanner" \
      org.opencontainers.image.documentation="Mount /scan volume and set TOOL env var"
