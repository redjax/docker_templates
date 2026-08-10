import subprocess
import logging
import argparse
import datetime as dt
from pathlib import Path
import time
import shutil


log = logging.getLogger(__name__)

## Path to documents in Paperless container
CONTAINER_DOCS_DIR = "/usr/src/paperless/data"
## Path to media in Paperless container
CONTAINER_MEDIA_DIR = "/usr/src/paperless/media"


def parse_args():
    parser = argparse.ArgumentParser("paperless-backup")
    
    parser.add_argument("-d", "--debug", action="store_true", help="Enable debug logging")
    parser.add_argument("--container-name", type=str, default="paperless-server", help="Name of the Paperless container")
    parser.add_argument("--backup-path", type=str, default="./backup/paperless", help="Path on host where backup should be created")
    parser.add_argument("--trim-backups", action="store_true", help="Trim backups by deleting backups older than N days, where N is the value of the --backup-retain-days argument")
    parser.add_argument("--backup-retain-days", type=int, default=3, help="Number of backups to retain when running with --trim-backups")

    args = parser.parse_args()
    
    return args


def get_ts(safe_str: bool):
    if safe_str:
        return dt.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    else:
        return dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def check_docker_installed():
    try:
        result = subprocess.run(
            ["docker", "--version"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        return result.returncode == 0
    except FileNotFoundError:
        return False


def check_compose_installed():
    try:
        result = subprocess.run(
            ["docker", "compose", "version"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        if result.returncode == 0:
            return True
    except FileExistsError:
        return False
    
    
def run_cmd(cmd, check=True):
    """Run a shell command and print output."""
    
    log.info(f"Running: {' '.join(cmd) if isinstance(cmd, list) else cmd}")
    
    result = subprocess.run(cmd, shell=isinstance(cmd, str), check=check, capture_output=True, text=True)
    
    if result.stdout:
        log.info(result.stdout)
    if result.stderr:
        log.error(result.stderr)
    
    return result


def ensure_paths_exist(dirs: list[str]):
    if not dirs or isinstance(dirs, list) and len(dirs) == 0:
        raise ValueError("List of directories cannot be None and must have at least 1 path.")
    
    dirs_count = len(dirs)
    if dirs_count == 1:
        log.info(f"Creating 1 directory")
        log.debug(f"Directory: {dirs[0]}")
    if dirs_count < 10:
        log.info(f"Creating {dirs_count} directories")
        log.debug(f"Directories to create: {dirs}")
    else:
        log.info(f"Creating {dirs_count} directories")
        
    errors: list[dict] = []
    existed: list[str] = []
    created: list[str] = []
    
    for d in dirs:
        if not Path(str(d)).exists():
            try:
                Path(str(d)).mkdir(exist_ok=True, parents=True)
                created.append(d)
            except Exception as exc:
                log.error(f"Error creating path: {d}. Details: {exc}")
                errors.append({"path": d, "error": exc})
                
                continue
        else:
            existed.append(d)
            
    if len(created) > 0:
        log.info(f"Created [{len(created)}] dir(s)")
    if len(errors) > 0:
        log.info(f"Errored while creating [{len(errors)}] dir(s)")
        log.info("Errors:")
        for e in errors:
            log.warning(f"Failed creating directory '{e['path']}'. Error: {e['error']}")
    if len(existed) > 0:
        log.info(f"Skipped [{len(existed)}] dir(s) because they already existed.")


def trim_backups(scan_dir: str, day_threshold: int):
    if not scan_dir or not Path(str(scan_dir)).exists():
        raise ValueError("scan_dir must be a valid path that exists")
    if day_threshold == 0:
        log.warning("day_threshold cannot be 0. Defaulting to 3.")
        day_threshold = 3
    
    now = time.time()
    cutoff = now - (day_threshold * 86400)
    
    scan_dir: Path = Path(str(scan_dir))
    
    entries = list(scan_dir.iterdir())
    
    if len(entries) == 0:
        log.warning(f"No files found in path '{scan_dir}'. Skipping backup trim.")
        return

    log.info(f"Scanning path '{scan_dir}' for backups older than {day_threshold} day(s)")
    
    deleted = []
    errors = []
    
    ## Loop over files in scan_dir
    for file_path in scan_dir.rglob('*'):
        ## Check if path is a file
        if file_path.is_file():
            ## Check if path is older than cutoff date
            if file_path.stat().st_mtime < cutoff:
                ## Delete path if it's older than 3 days
                try:
                    file_path.unlink()
                    log.info(f"Deleted: {file_path}")
                    deleted.append(file_path)
                except Exception as e:
                    log.error(f"Error deleting {file_path}: {e}")
                    errors.append({"path": file_path, "error": e})
                    continue
                
    if len(deleted) > 0:
        log.info(f"Deleted [{len(deleted)}] dir(s)")
        log.debug(f"Deleted dirs: {deleted}")
        
    if len(errors):
        log.warning(f"Errored while deleting [{len(deleted)}] dir(s)")
        log.debug(f"Errors while deleting paths: {errors}")


def backup_paperless_documents(backup_path: str, container_name: str):
    log.info("START Paperless backup")

    timestamp = get_ts(safe_str=True)
    
    documents_backup_dir = f"{backup_path}/data/{timestamp}"
    media_backup_dir = f"{backup_path}/media/{timestamp}"
    final_backup_dir = f"{backup_path}/backup/paperless-data"
    
    log.info(f"Backing up Paperless docs to {documents_backup_dir}")
    run_cmd(
        [
            "docker",
            "cp",
            f"{container_name}:{CONTAINER_DOCS_DIR}",
            documents_backup_dir
        ]
    )

    log.info(f"Backing up Paperless media to {media_backup_dir}")
    run_cmd(
        [
            "docker", 
            "cp", 
            f"{container_name}:{CONTAINER_MEDIA_DIR}", 
            media_backup_dir
        ]
    )

    log.info(f"Archiving {media_backup_dir}")
    run_cmd(
        [
            "tar",
            "-czvf",
            f"{media_backup_dir}.tar.gz", media_backup_dir
        ]
    )

    log.info(f"Removing {media_backup_dir}")
    Path(str(media_backup_dir)).unlink(missing_ok=True)

    log.info(f"Archiving {documents_backup_dir}")
    run_cmd(
        [
            "tar",
            "-czvf",
            f"{documents_backup_dir}.tar.gz",
            documents_backup_dir
        ]
    )

    log.info(f"Removing {documents_backup_dir}")
    Path(str(documents_backup_dir)).unlink(missing_ok=True)

    if not Path(str(final_backup_dir)).is_dir():
        log.info(f"Creating {final_backup_dir}")
        Path(str(final_backup_dir)).mkdir(parents=True, exist_ok=True)

    log.info(f"Moving backups to {final_backup_dir}")

    data_dir = Path(f"{final_backup_dir}/data")
    media_dir = Path(f"{final_backup_dir}/media")

    if not Path(data_dir).exists():
        log.info(f"Creating {data_dir}")
        Path(str(data_dir)).mkdir(parents=True, exist_ok=True)

    if not Path(str(media_dir)).exists():
        log.info(f"Creating {media_dir}")
        Path(str(media_dir)).mkdir(parents=True, exist_ok=True)

    ## Move data files
    for file in Path(f"{final_backup_dir}/data").rglob("*"):
        src = Path(f"{final_backup_dir}/data/{file}")
        
        log.info(f"Moving file: {src} to: {data_dir}")
        shutil.move(src, data_dir)

    ## Move media files
    for file in Path(f"{final_backup_dir}/media").rglob("*"):
        src = Path(f"{final_backup_dir}/media/{file}")
        
        log.info(f"Moving file: {src} to: {media_dir}")
        shutil.move(src, media_dir)


def main(args: argparse.Namespace):
    log_level: str = "DEBUG" if args.debug else "INFO"
    log_fmt: str = "%(asctime)s | %(levelname)s | %(module)s.%(funcName)s:%(lineno)s :: %(message)s" if args.debug else "%(asctime)s | %(levelname)s :: %(message)s"
    log_datefmt: str = "%Y-%m-%d %H:%M:%S" if args.debug else "%H:%M"
    
    logging.basicConfig(level=log_level, format=log_fmt, datefmt=log_datefmt)
    log.debug("DEBUG logging enabled")
    
    ## Directories to create
    create_dirs: list[str] = [
        args.backup_path,
    ]
    
    docker_installed = check_docker_installed()
    compose_installed = check_compose_installed()
    
    log.debug(f"Found Docker: {docker_installed}")
    log.debug(f"Found Docker Compose: {compose_installed}")
    
    if docker_installed and compose_installed:
        log.info("Found Docker and Docker Compose")
    elif docker_installed and not compose_installed:
        log.error("Found Docker, but Docker Compose is not installed")
        exit(1)
    elif not docker_installed and compose_installed:
        log.error("Docker is not installed, but found Doccker Compose")
        exit(1)
    else:
        log.error("Could not find Docker or Docker Compose")
        exit(1)
        
    ## Create directories
    try:
        ensure_paths_exist(dirs=create_dirs)
    except Exception as exc:
        log.error(f"Error creating backup directories. Details: {exc}")
    
    ## Do backups
    try:
        backup_paperless_documents(backup_path=args.backup_path, container_name=args.container_name)
    except Exception as exc:
        log.error(f"Error creating Paperless backup. Details: {exc}")
        raise
    
    ## Trim backups
    if args.trim_backups:
        try:
            trim_backups(scan_dir=args.backup_path, day_threshold=args.backup_retain_days)
        except Exception as exc:
            log.error(f"Failed to trim backups. Details: {exc}")
            raise


if __name__ == "__main__":
    args = parse_args()
    
    main(args)
