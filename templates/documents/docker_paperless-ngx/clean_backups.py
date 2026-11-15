from pathlib import Path
import typing as t
import os
import shutil
from datetime import datetime
import argparse

from dataclasses import dataclass, field

BACKUP_DIR: Path = Path("./backup")
PAPERLESS_EXPORT_BACKUP_DIR: Path = BACKUP_DIR / "paperless" / "exports"

TS_FORMAT: str = "%Y-%m-%d_%H:%M"

KEEP_BACKUPS: int = 7


@dataclass
class ScannedFile:
    path: t.Union[str, Path] = field(default=None)
    created_time: t.Union[int, float, datetime] = field(default=None)

    def __post_init__(self):
        if isinstance(self.path, str):
            self.path = Path(self.path)

        if isinstance(self.created_time, (int, float)):
            self.created_time = convert_unix_ts_to_dt(self.created_time)


def convert_unix_ts_to_dt(ts: t.Union[int, float] = None) -> datetime:
    assert ts is not None, ValueError("Missing input timestamp")
    assert isinstance(ts, (int, float)), TypeError(
        f"Input timestamp should be of type int or float. Got type: ({type(ts)})"
    )

    try:
        return datetime.utcfromtimestamp(ts).strftime(TS_FORMAT)
    except Exception as exc:
        msg = Exception(
            f"Unhandled exception converting input timestamp '{ts}' to Python datetime. Details: {exc}"
        )
        print(f"[ERROR] {msg}")

        raise msg


def scan_dir(
    p: t.Union[str, Path] = None, follow_symlinks: bool = False
) -> t.Generator[Path, None, None]:
    """Recursively yield files for a given directory path."""
    assert p is not None, ValueError("p cannot be None")
    assert isinstance(p, (str, Path)), TypeError(
        f"p must be of type str or Path. Got type: ({type(p)})"
    )

    if isinstance(p, str):
        p = Path(p)

    if not p.exists():
        print(f"[ERROR] Could not find path: {p}")
        return

    if p.is_file():
        print(f"[ERROR] '{p}' is a file. Scan dir should be a directory.")
        return

    try:
        for entry in os.scandir(p):
            if entry.is_dir(follow_symlinks=follow_symlinks):
                yield from scan_dir(entry.path, follow_symlinks=follow_symlinks)
            else:
                yield Path(entry.path)
    except Exception as exc:
        msg = Exception(f"Unhandled exception scanning path '{p}'. Details: {exc}")
        print(f"[ERROR] {msg}")


def clean_dir(
    p: t.Union[str, Path] = None,
    follow_symlinks: bool = False,
    dry_run: bool = False,
    keep_backups: int = KEEP_BACKUPS,
) -> list[ScannedFile]:
    assert p is not None, ValueError("Missing an input path to clean")
    assert isinstance(p, (str, Path)), TypeError(
        f"Input path must be of type str or Path. Got type: ({type(p)})"
    )

    if isinstance(p, str):
        p = Path(p)

    if not p.exists():
        print(f"[WARN] Backup path does not exist, skipping: '{p}'")
        return []

    print(f"Scanning for files in path '{p}'")

    try:
        _files = list(scan_dir(p=p, follow_symlinks=follow_symlinks))
        print(f"Found [{len(_files)}] file(s) in path '{p}'")
    except Exception as exc:
        msg = Exception(
            f"Unhandled exception getting list of files in path: '{p}'. Details: {exc}"
        )
        print(f"[ERROR] {msg}")

        raise msg

    file_objs: list[ScannedFile] = []

    for f in _files:
        file_objs.append(
            ScannedFile(
                path=f,
                created_time=f.stat().st_ctime,
            )
        )

    file_objs.sort(key=lambda x: x.created_time)

    if len(file_objs) <= keep_backups:
        print(
            f"Backup count [{len(file_objs)}] is less than or equal to the backup "
            f"limit of [{keep_backups}]. Skipping cleanup."
        )

        return file_objs

    print(
        f"Backup count [{len(file_objs)}] is greater than the backup limit of "
        f"[{keep_backups}]"
    )

    rm_backups: list[ScannedFile] = file_objs[:-keep_backups]

    print(
        f"Removing [{len(rm_backups)}] backup(s) to retain the newest "
        f"[{keep_backups}] backup(s)."
    )

    for backup in rm_backups:
        if backup.path.is_file():
            if dry_run:
                print(f"[DRY RUN] Would remove file: '{backup.path}'")
                continue

            try:
                backup.path.unlink()
                print(f"[SUCCESS] Removed file '{backup.path}'")
            except Exception as exc:
                msg = Exception(
                    f"Unable to remove file '{backup.path}'. Details: {exc}"
                )
                print(f"[ERROR] {msg}")
        else:
            if dry_run:
                print(f"[DRY RUN] Would remove directory: '{backup.path}'")
                continue

            try:
                shutil.rmtree(backup.path)
                print(f"[SUCCESS] Removed directory '{backup.path}'.")
            except Exception as exc:
                msg = Exception(
                    f"Unable to remove directory '{backup.path}'. Details: {exc}"
                )
                print(f"[ERROR] {msg}")

    return file_objs


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Clean old Paperless export backups."
    )

    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print files that would be removed without deleting them.",
    )
    parser.add_argument(
        "--keep",
        type=int,
        default=KEEP_BACKUPS,
        help=f"Number of newest backups to keep. Default: {KEEP_BACKUPS}.",
    )
    parser.add_argument(
        "--backup-dir",
        type=Path,
        default=PAPERLESS_EXPORT_BACKUP_DIR,
        help=(
            "Directory containing Paperless export backups to clean. "
            f"Default: {PAPERLESS_EXPORT_BACKUP_DIR}."
        ),
    )

    return parser.parse_args()


def main(
    dry_run: bool = False,
    keep_backups: int = KEEP_BACKUPS,
    backup_dir: Path = PAPERLESS_EXPORT_BACKUP_DIR,
) -> None:
    clean_dir(
        p=backup_dir,
        dry_run=dry_run,
        keep_backups=keep_backups,
    )


if __name__ == "__main__":
    args = parse_args()

    print(f"Backup path: {args.backup_dir}")
    print(f"Dry run: {args.dry_run}")
    print(f"Keep backups: {args.keep}")

    main(
        dry_run=args.dry_run,
        keep_backups=args.keep,
        backup_dir=args.backup_dir,
    )

