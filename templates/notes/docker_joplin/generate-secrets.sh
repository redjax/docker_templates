#!/usr/bin/env bash

# Generate strong random passwords (32 chars base64-ish)
DB_PASSWORD=$(openssl rand -base64 32 | tr -d '\n' | tr -d '/+=' | cut -c1-32)
ADMIN_PASSWORD=$(openssl rand -base64 32 | tr -d '\n' | tr -d '/+=' | cut -c1-32)

echo "DB_PASSWORD=$DB_PASSWORD"
echo "ADMIN_PASSWORD=$ADMIN_PASSWORD"

# Optional: save to file
cat <<EOF > joplin-passwords.env
DB_PASSWORD=$DB_PASSWORD
ADMIN_PASSWORD=$ADMIN_PASSWORD
EOF

echo "Saved to joplin-passwords.env"

