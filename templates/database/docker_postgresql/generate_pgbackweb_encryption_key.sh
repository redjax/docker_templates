#!/bin/bash

OUTPUT_FILE="pgbackweb_encryption_key_DELETE_WHEN_DONE.bin"
openssl rand -base64 32 > $OUTPUT_FILE || { echo "Generation failed"; exit 1; }
