#!/usr/bin/env bash
set -euo pipefail

BOOTSTRAP_DIR="/tmp/netbird-bootstrap"
mkdir -p "${BOOTSTRAP_DIR}"

echo "Bootstrapping NetBird"

curl -fsSL https://github.com/netbirdio/netbird/releases/latest/download/getting-started.sh | bash -s -- "${BOOTSTRAP_DIR}"

cat << EOF
Bootstrap complete. Files are in:
  ${BOOTSTRAP_DIR}

!! Do NOT delete them yet !!

Manually copy:
  - config.yaml -> config.yaml.template
  - dashboard.env -> dashboard.env.template

Then edit both files and replace the hardcoded values with env vars:
  exposedAddress: "https://\${NETBIRD_DOMAIN}"
  auth.issuer: "https://\${NETBIRD_DOMAIN}"
  authSecret: "\${NETBIRD_AUTH_SECRET}"
  encryptionKey: "\${NETBIRD_STORE_ENCRYPTION_KEY}"

You should also edit the config.yaml.template's trustedHTTPProxies line, which defaults to something like `172.30.0.10/32`. You should instead use:

  trustedHTTPPRoxies:
    - "127.0.0.1/32"
    - "172.16.0.0/12"
    - "10.0.0.0/8"

You should also remove the `LETSENCRYPT_DOMAIN=none` var, or set it to empty like: `LETSENCRYPT_DOMAIN=`

Then run:
  ./scripts/render-config.sh
EOF

