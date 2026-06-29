#!/usr/bin/env bash
set -euo pipefail

##############################################################
# Deletes Miniflux database backups from a directory         #
#                                                            # 
# All backups are deleted unless a --retain value is passed. #
#                                                            #
# With --retain, the newest N backups are kept.              #
##############################################################

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
DOCKER_ROOT=$(realpath -m "${THIS_DIR}/..")

cd "${DOCKER_ROOT}"

## Configuration defaults
BACKUP_DIR="${BACKUP_DIR:-./backups}"
RETAIN="${RETAIN:-0}"

## Usage function
function usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Delete old Miniflux database backups, optionally retaining the N newest backups.

Options:
  --backup-dir  PATH   Backup directory (default: ./backups)
  --retain      N      Retain the N newest backups (default: 0, meaning delete all)
  --dry-run            Show what would be deleted without actually deleting
  -h, --help           Show this help message

Arguments:
  N must be 1 or greater when using --retain

Examples:
  $0 --retain 7              # Keep the 7 newest backups, delete the rest
  $0 --retain 1              # Keep only the newest backup
  $0 --dry-run               # Show what would be deleted without deleting
  $0 --backup-dir /mnt/backups --retain 5
EOF
}

## Parse command-line arguments
DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case $1 in
    --backup-dir)
      BACKUP_DIR="$2"
      shift 2
      ;;
    --retain)
      RETAIN="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      echo "Use --help for usage information" >&2
      exit 1
      ;;
    *)
      echo "Error: Unknown argument: $1" >&2
      echo "Use --help for usage information" >&2
      exit 1
      ;;
  esac
done

## Validate RETAIN is a number >= 0
if ! [[ "$RETAIN" =~ ^[0-9]+$ ]]; then
  echo "Error: --retain must be a number (0 or greater)" >&2
  exit 1
fi

if [ "$RETAIN" -gt 0 ] && [ "$RETAIN" -lt 1 ]; then
  echo "Error: --retain must be 1 or greater when specified" >&2
  exit 1
fi

## Validate backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
  echo "Error: Backup directory not found: $BACKUP_DIR" >&2
  exit 1
fi

## Count total backups
TOTAL_BACKUPS=$(find "$BACKUP_DIR" -maxdepth 1 -name 'miniflux_*.sql*' -type f | wc -l)

if [ "$TOTAL_BACKUPS" -eq 0 ]; then
  echo "No backups found in $BACKUP_DIR"
  exit 0
fi

echo "Found $TOTAL_BACKUPS backup(s) in $BACKUP_DIR"

## Get list of backups sorted by name (newest first, since they're timestamped)
BACKUPS=$(find "$BACKUP_DIR" -maxdepth 1 -name 'miniflux_*.sql*' -type f | sort -r)

## Determine how many to delete
if [ "$RETAIN" -eq 0 ]; then
  TO_DELETE="$TOTAL_BACKUPS"
  echo "Retain not set, will delete all $TOTAL_BACKUPS backup(s)"
elif [ "$RETAIN" -ge "$TOTAL_BACKUPS" ]; then
  TO_DELETE=0
  echo "Retaining $RETAIN newest backup(s), but only $TOTAL_BACKUPS exist. Nothing to delete."
else
  TO_DELETE=$((TOTAL_BACKUPS - RETAIN))
  echo "Retaining $RETAIN newest backup(s), will delete $TO_DELETE backup(s)"
fi

if [ "$TO_DELETE" -eq 0 ]; then
  echo "Nothing to delete"
  exit 0
fi

if [ "$DRY_RUN" -eq 1 ]; then
  echo ""
  echo "DRY RUN - Would delete the following backups:"
  echo ""
  echo "$BACKUPS" | head -n "$TO_DELETE"
  echo ""
  echo "Run without --dry-run to actually delete these files."
else
  echo ""
  echo "Deleting backups"
  echo ""
  
  DELETED=0
  echo "$BACKUPS" | head -n "$TO_DELETE" | while read -r backup; do
    echo "Deleting: $backup"
    rm -f "$backup"
    DELETED=$((DELETED + 1))
  done
  
  echo ""
  echo "Deleted $TO_DELETE backup(s)"
fi

## Show remaining backups
REMAINING=$(find "$BACKUP_DIR" -maxdepth 1 -name 'miniflux_*.sql*' -type f | wc -l)
echo "Remaining backups: $REMAINING"
