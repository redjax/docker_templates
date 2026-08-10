import logging
import argparse
from pathlib import Path

log = logging.getLogger(__name__)

def parse_args():
    parser = argparse.ArgumentParser("palworld_backup", description="Manage Palworld backups")

    parser.add_argument("--debug", action="store_true", help="Enable debug logging")
    parser.add_argument("--backup-dir", type=str, default="./palworld/backups", help="Path to Palworld backups directory")
    parser.add_argument("--retain", type=int, default=10, help="Ensure a number of backups are retained")

    args = parser.parse_args()

    return args


def delete_backups(backups_dir: Path, retain: int):
    if not backups_dir:
        raise ValueError("Missing a backups_dir")
    if not isinstance(backups_dir, Path):
        backups_dir: Path = Path(str(backups_dir))
    if not backups_dir.exists():
        raise FileNotFoundError(f"Could not find backups directory at path: {backups_dir}")

    backups = sorted([f for f in backups_dir.iterdir() if f.is_file()], key=lambda f: f.stat().st_mtime)
    excess = len(backups) - retain

    if excess <= 0:
        log.info(f"Total backups ({len(backups)}) does not exceed retain count. No backups will be deleted")
        return

    deleted = 0
    errored: list[Path] = []

    log.info(f"Deleting ({excess}) backups")
    for f in backups[:excess]:
        log.debug(f"Delete backup: {f}")
        try:
            f.unlink()
            log.info(f"Deleted backup: {f}")
            deleted+=1
        except Exception as exc:
            log.error(f"Error deleting backup '{f}'. Details: {exc}")
            errored.append(f)
            continue

    log.info(f"Deleted [{deleted}] backup(s)")
    if len(errored) > 0:
        log.warning(f"Failed deleting [{len(errored)}] backup(s)")
        log.debug(f"Errored on: {errored}")


def main():
    args = parse_args()

    log_level = "DEBUG" if args.debug else "INFO"
    log_fmt = "%(asctime)s | [$(levelname)s] | %(module)s.%(funcName)s:%(lineno)s :: %(message)s" if log_level == "DEBUG" else "%(asctime)s | [%(levelname)s] :: %(message)s"
    logging.basicConfig(
        level=log_level,
        format=log_fmt,
        datefmt="%Y-%m-%d %H:%M:%S"
    )

    log.debug("DEBUG logging enabled")

    backups_dir = Path(args.backup_dir)
    if not backups_dir.exists():
        raise FileNotFoundError(f"Could not find Palworld backups directory at path: {backups_dir}")

    log.debug(f"Found Palworld backups directory at path: {backups_dir}")
    if not any(backups_dir.iterdir()):
        log.warning(f"Backups directory is empty: {backups_dir}")
        return

    log.info(f"Cleaning Palworld backups at path: {backups_dir}")
    try:
        delete_backups(backups_dir=backups_dir, retain=args.retain)
    except Exception as exc:
        log.error(f"Error deleting backups: {exc}")


if __name__ == "__main__":
    main()

