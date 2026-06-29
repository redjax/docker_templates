#!/bin/bash

## Default values
URL="http://gitlab-server"
VALID_EXECUTORS=("shell" "docker" "docker+machine" "docker-autoscaler" "kubernetes" "ssh" "virtualbox" "parallels" "custom" "instance")
EXECUTOR="docker"
TOKEN=""
DESCRIPTION="docker-runner"
DOCKER_IMAGE="cgr.dev/chainguard/wolfi-base"
TAG_LIST=""
RUN_UNTAGGED="true"
LOCKED="false"

print_usage() {
    echo "Usage: $0 --token <token> [--url <url>] [--executor <executor>] [--description <desc>] [--docker-image <image>] [--tag-list <tags>] [--run-untagged <true|false>] [--locked <true|false>]"
    echo ""
    echo "Tags should be comma-separated, i.e. docker,ci,linux"
    echo "Executor options are: shell, docker, docker+machine, docker-autoscaler, kubernetes, ssh, virtualbox, parallels, custom, instance"
}

## Parse CLI args
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --token)
            if [[ -z "$2" ]]; then
                echo "[ERROR] Registration token (--token) is required"
                print_usage
                exit 1
            fi

            TOKEN="$2"
            shift 2
            ;;
        --url)
            if [[ -z "$URL" ]]; then
                echo "[ERROR] URL (--url) is required"
                print_usage
                exit 1
            fi

            URL="$2"
            shift 2
            ;;
        --executor)
            if [[ -z "$2" ]]; then
                echo "[ERROR] Executor (--executor) is required"
                print_usage
                exit 1
            fi

            EXECUTOR="$2"
            shift 2
            ;;
        --description)
            if [[ -z "$2" ]]; then
                echo "[ERROR] Description (--description) is required"
                print_usage
                exit 1
            fi

            DESCRIPTION="$2"
            shift 2
            ;;
        --docker-image)
            if [[ -z "$2" ]]; then
                echo "[ERROR] Docker image (--docker-image) is required"
                print_usage
                exit 1
            fi

            DOCKER_IMAGE="$2"
            shift 2
            ;;
        --tag-list)
            if [[ -z "$2" ]]; then
                echo "[ERROR] Tag list (--tag-list) is required"
                print_usage
                exit 1
            fi

            TAG_LIST="$2"
            shift 2
            ;;
        --run-untagged)
            if [[ -z "$2" ]]; then
                echo "[ERROR] Run untagged jobs (--run-untagged) is required"
                print_usage
                exit 1
            fi

            RUN_UNTAGGED="$2"
            shift 2
            ;;
        --locked)
            if [[ -z "$2" ]]; then
                echo "[ERROR] Locked (--locked) is required"
                print_usage
                exit 1
            fi

            LOCKED="$2"
            shift 2
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            print_usage
            exit 1
            ;;
    esac
done

if [[ -z "$TOKEN" ]]; then
    echo "[ERROR] Registration token (--token) is required"
    print_usage
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "[ERROR] Docker is not installed. Install Docker and try again."
    exit 1
fi

## Lowercase input executor string
EXECUTOR=$(echo "$EXECUTOR" | tr '[:upper:]' '[:lower:]')

## Validate executor
if [[ ! " ${VALID_EXECUTORS[@]} " =~ " $EXECUTOR " ]]; then
    echo "[ERROR] Invalid executor: $EXECUTOR"
    echo "Valid executors are: ${VALID_EXECUTORS[@]}"
    exit 1
fi

echo "Registering Gitlab runner with:"
echo "  URL: $URL"
echo "  Token: [HIDDEN]"
echo "  Executor: $EXECUTOR"
echo "  Description: $DESCRIPTION"
echo "  Docker Image: $DOCKER_IMAGE"
echo "  Tag list: $TAG_LIST"
echo "  Run untagged jobs: $RUN_UNTAGGED"
echo "  Locked: $LOCKED"
echo ""

docker run --rm -v $(pwd)/gitlab-runner/config:/etc/gitlab-runner gitlab/gitlab-runner:latest register \
  --non-interactive \
  --url "$URL" \
  --registration-token "$TOKEN" \
  --executor "$EXECUTOR" \
  --docker-image "$DOCKER_IMAGE" \
  --description "$DESCRIPTION" \
  --tag-list "$TAG_LIST" \
  --run-untagged="$RUN_UNTAGGED" \
  --locked="$LOCKED"

if [[ $? -ne 0 ]]; then
    echo "[ERROR] Failed to register Gitlab runner"
    exit 1
else
    echo "Gitlab runner registered successfully. Restart the Compose stack to bring the embedded runner up."
    exit 0
fi
