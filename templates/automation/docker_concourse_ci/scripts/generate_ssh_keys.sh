#!/usr/bin/env bash

_MSYSTEM="$MSYSTEM"
set -e -u

echo "Generating TSA keys for Concourse CI."

mkdir -p keys
cd keys

WORK_DIR="$PWD"
_MSYSTEM="${MSYSTEM:=}"
if [ "$_MSYSTEM" == "MINGW64" ]; then
  WORK_DIR="$(cygpath -t windows $(pwd))"
fi

docker run --rm -v "$WORK_DIR/web":/keys concourse/concourse \
  generate-key -t rsa -f /keys/session_signing_key

docker run --rm -v "$WORK_DIR/web":/keys concourse/concourse \
  generate-key -t ssh -f /keys/tsa_host_key

docker run --rm -v "$WORK_DIR/worker":/keys concourse/concourse \
  generate-key -t ssh -f /keys/worker_key

cp ./worker/worker_key.pub ./web/authorized_worker_keys
cp ./web/tsa_host_key.pub ./worker

echo "Created keys at path $(pwd)/web/ and $(pwd)/worker/"
