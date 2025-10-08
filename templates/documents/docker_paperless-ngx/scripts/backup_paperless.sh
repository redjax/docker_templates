#!/usr/bin/env bash

THIS_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT=$( cd -- "$THIS_DIR/.." &> /dev/null && pwd )

EXPORT_DEST="${PROJECT_ROOT}/backup/paperless/exports"
EXPORT_HOST_MOUNT="${PROJECT_ROOT}/data/paperless/export"

DO_CLEANUP="false"

function logger() {
    echo "[$(date +'%F %H:%M:%S')] ${@}"
}

function print_help() {
    echo ""
    echo "Docker Paperless NGX - Export documents"
    echo ""
    echo "Description:"
    echo "  Exports data from Paperless to a destination on the host."
    echo "  Assumes you are using a host volume mount in the compose.yml,"
    echo "    i.e. ./data/paperless/export: /usr/src/paperless/export"
    echo ""
    echo "Options:"
    echo "  -e | --export-dest   Path where exports should be moved to after creation."
    echo "  -c | --cleanup       Run cleanup operations, removing old backups in the export destination."
    echo "  -r | --retain-count  Number of recent backups to keep (default: 10)."
    echo "  -h | --help          Print the help menu."
    echo ""
}

function parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
        -e | --export-dest)
            if [[ -z "$2" || "$2" == -* ]]; then
                logger "[ERROR] --export-dest provided, but no export destination path given."
                print_help
                exit 1
            fi
            EXPORT_DEST="$2"
            shift 2
            ;;
        -c | --cleanup)
            DO_CLEANUP="true"
            shift
            ;;
        -r | --retain-count)
            if [[ -z "$2" || "$2" == -* || "$2" =~ [^0-9] ]]; then
                logger "[ERROR] --retain-count requires a positive integer argument."
                print_help
                exit 1
            fi
            RETAIN_COUNT="$2"
            shift 2
            ;;
        -h | --help)
            print_help
            exit 0
            ;;
        *)
            logger "[ERROR] Invalid argument: $1"
            print_help
            exit 1
            ;;
    esac
  done
}

function cleanup_backups() {
    logger "[CLEANUP] Retaining ${RETAIN_COUNT} most recent backup(s) in '${EXPORT_DEST}'"

    local backups
    
    mapfile -t backups < <(ls -1t "${EXPORT_DEST}"/*.zip 2> /dev/null)
    
    local total=${#backups[@]}
    
    if (( total <= RETAIN_COUNT )); then
        logger "No backups removed. Total backups (${total}) <= retain count (${RETAIN_COUNT})"
        return 0
    fi
    
    local to_delete=$(( total - RETAIN_COUNT ))
    
    logger "Removing ${to_delete} oldest backup(s)..."
    
    for (( i=RETAIN_COUNT; i < total; i++ )); do
        
        logger "Removing: ${backups[$i]}"
        
        rm -f "${backups[$i]}"
        if [[ $? -ne 0 ]]; then
            logger "[ERROR] Failed to remove backup: ${backups[$i]}"
            return 1
        fi

    done

    logger "Cleanup completed."
}

if ! command -v docker compose &> /dev/null; then
    logger "[ERROR] Docker compose is not installed."
    exit 1
fi

parse_args "${@}"

if [[ ! -d "${EXPORT_DEST}" ]]; then
  logger "[WARNING] Creating backup path (does not exist): ${EXPORT_DEST}"
  mkdir -p "${EXPORT_DEST}"
  if [[ $? -ne 0 ]]; then
      logger "[ERROR] Failed to create backup directory."
      exit $?
  fi
fi

EXPORT_FILENAME="$(date +'%Y%m%d%H%M%S')_paperless-ngx_export"
EXPORT_FILE_PATH="${EXPORT_HOST_MOUNT}/${EXPORT_FILENAME}.zip"

echo ""
logger "Creating Paperless NGX export"

echo ""

echo "  Export host mount:"
echo "    ${EXPORT_HOST_MOUNT}"
echo ""
echo "  Export to:"
echo "    ${EXPORT_FILE_PATH}"
echo ""
echo "  Move to:"
echo "    ${EXPORT_DEST}"
echo ""

logger "  Running command: docker compose exec -T webserver document_exporter ../export --delete --zip --zip-name \"${EXPORT_FILENAME}\""

## Run backup command 
docker compose exec -T webserver document_exporter ../export --delete --zip --zip-name "${EXPORT_FILENAME}"
if [[ $? -ne 0 ]]; then
  logger "[ERROR] Failed to create Paperless export."
  exit 1
else
  echo ""
  logger "Finished exporting data."
  if [[ -f "${EXPORT_FILE_PATH}" ]]; then
    logger "Created archive: ${EXPORT_FILE_PATH}"
  else
    logger "[ERROR] Archive not found at path '$EXPORT_FILE_PATH'."
    exit 1
  fi
fi

echo ""

if [[ ! -d "${EXPORT_DEST}" ]]; then
    logger "[WARNING] Creating export destination (does not exist): '${EXPORT_DEST}'"
    sudo mkdir -p "${EXPORT_DEST}"
    if [[ $? -ne 0 ]]; then
        logger "[ERROR] Failed to create path '${EXPORT_DEST}'."
        logger "Trying again with sudo"

        sudo mkdir -p "${EXPORT_DEST}"
        if [[ $? -ne 0 ]]; then
            logger "[ERROR] Failed to create export destination path '${EXPORT_DEST}'"
            exit $?
        fi
    fi
fi

echo ""
logger "Moving backup to ${EXPORT_DEST}"

mv "${EXPORT_FILE_PATH}" "${EXPORT_DEST}"
if [[ $? -ne 0 ]]; then
    echo ""
    logger "[ERROR] Failed to move export archive '${EXPORT_FILE_PATH}' to destination '${EXPORT_DEST}'"
    logger "Trying again with sudo"
    
    sudo mv "${EXPORT_FILE_PATH}" "${EXPORT_DEST}"
    if [[ $? -ne 0 ]]; then
        logger "[ERROR] Failed to create path: ${EXPORT_DEST}"
        exit $?
    fi
fi    

echo ""
logger "Moved backup to:"
echo "    ${EXPORT_DEST}/${EXPORT_FILE_PATH}"

## Run cleanup if requested
if [[ "${DO_CLEANUP}" == "true" ]]; then
  echo ""
  cleanup_backups
  echo ""
fi

logger "Finished Paperless NGX backup"

echo ""
exit 0

