#!/bin/bash

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERLAYS_DIR="${THIS_DIR}/overlays"
PG_OVERLAY="${OVERLAYS_DIR}/postgres.yml"
UI_OVERLAY="${OVERLAYS_DIR}/temporal-ui.yml"
ADMINTOOLS_OVERLAY="${OVERLAYS_DIR}/temporal-admin-tools.yml"

NAMESPACE="default"
OPERATION="create"
TEMPORAL_ADDRESS="localhost:7233"

function print_help() {
    echo ""
    echo "[Temporal Namespace Management]"
    echo " Creates or deletes a Temporal namespace."
    echo ""
    echo " Usage: $0 [options]"
    echo "   -n|--namespace <namespace>"
    echo "   -o|--operation <create|new / delete|rm|remove>"
    echo "   -t|--temporal-address <address>"
    echo ""
    echo " Options:"
    echo "   -h|--help      Print this help message."
    echo ""
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--namespace)
      if [[ -z "$2" ]]; then
        echo "Option $1 requires an argument."
        print_help
        exit 1
      fi
      NAMESPACE="$2"
      shift 2
      ;;
    -o|--operation)
      if [[ -z "$2" ]]; then
        echo "Option $1 requires an argument (create|delete)."
        print_help
        exit 1
      fi

      OPERATION="$2"
      shift 2
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      echo "Unknown option $1"
      print_help
      exit 1
      ;;
  esac
done

case "$OPERATION" in
  create|new)
    CMD=(
      docker run --rm \
        --network=host \
        temporalio/temporal \
        operator namespace create \
        --namespace "$NAMESPACE" \
        --address "$TEMPORAL_ADDRESS"
    )
    ;;
  delete|rm|remove)
    CMD=(
      docker run --rm \
        --network=host \
        temporalio/temporal \
        operator namespace delete \
        --namespace "$NAMESPACE" \
        --address "$TEMPORAL_ADDRESS" \
        --yes
    )
    ;;
  *)
    echo "Invalid operation: $OPERATION. Must be 'create' or 'delete'."
    exit 1
    ;;
esac


echo ""
echo "Performing Temporal namespace operation: $OPERATION"
echo "Namespace: $NAMESPACE"
echo "Command:"
echo "  ${CMD[@]}"
echo ""

"${CMD[@]}"
if [[ $? -ne 0 ]]; then
  echo "Failed to $OPERATION temporal namespace."
  exit 1
fi
