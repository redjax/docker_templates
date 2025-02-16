#!/bin/bash

# read -sp "Graylog root password to hash: " PASSWORD

# PASSWORD_HASH=$(echo -n "${PASSWORD}" | shasum -a 256)

# echo "Password hash:"
# echo "${PASSWORD_HASH::-3}"

#!/bin/bash

HASH_OUTPUT_FILE="$(pwd)/password_hash"

## Prompt for the password securely
read -sp "Graylog root password to hash: " PASSWORD
echo

## Hash the password using sha256sum (secure and portable)
PASSWORD_HASH=$(echo -n "${PASSWORD}" | sha256sum | awk '{print $1}')

if [[ ! $? -eq 0 ]]; then
    echo "[ERROR] Failed to hash password."
    exit 1
fi

## Output the password hash
echo "Password hashed successfully. Saving to file: ${HASH_OUTPUT_FILE}"

## Write password hash & a message to file
cat <<EOF >$HASH_OUTPUT_FILE
Graylog Admin Password Hash:

    $PASSWORD_HASH

Save this password somewhere safe!

Copy and paste the hash above into the
'GRAYLOG_ROOT_PASSWORD_HASH' variable
in ./compose.yml.

!! DO NOT COMMIT THIS HASH FILE TO GIT !!

Once you have copied the password hash into
the compose.yml file, you should delete this
password hash file. It is insecure to leave it.

You can regenerate the same password hash by
re-running this script and typing the new password.
EOF

if [[ ! $? -eq 0 ]]; then
    echo "[ERROR] Failed to save password hash to file."
    exit 1
fi

echo ""
echo "Retrieve your hash from '${HASH_OUTPUT_FILE}'. Use this value in the 'GRAYLOG_ROOT_PASSWORD_HASH' variable in the 'docker-compose.yml' file."
echo ""
echo "!! DO NOT COMMIT YOUR PASSWORD HASH FILE TO GIT !!"
echo ""
