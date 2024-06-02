from pathlib import Path
import typing as t
import os
import shutil
from datetime import datetime

from dataclasses import dataclass, field

BACKUP_DIR: Path = Path("./backup")
PAPERLESS_BACKUP_ROOT_DIR: Path= Path(f"{BACKUP_DIR}/paperless-data")

DB_BACKUP_DIR: Path = Path(f"{BACKUP_DIR}/db")
PAPERLESS_DATA_BACKUP_DIR: Path = Path(f"{PAPERLESS_BACKUP_ROOT_DIR}/data")
PAPERLESS_MEDIA_BACKUP_DIR: Path = Path(f"{PAPERLESS_BACKUP_ROOT_DIR}/media")

TS_FORMAT: str = "%Y-%m-%d_%H:%M"

KEEP_BACKUPS: int = 7

@dataclass
class ScannedFile:
    path: t.Union[str, Path] = field(default=None)
    created_time: t.Union[int, float, datetime] = field(default=None)
    
    def __post_init__(self):
        if isinstance(self.path, str):
            self.path = Path(self.path)
        
        if isinstance(self.created_time, int) or isinstance(self.created_time, float):
            self.created_time: datetime = convert_unix_ts_to_dt(self.created_time)


def convert_unix_ts_to_dt(ts: t.Union[int, float] = None) ->  datetime:
    assert ts is not None, ValueError("Missing input timestamp")
    assert isinstance(ts, int) or isinstance(ts, float), TypeError(f"Input timestamp should be of type int or float. Got type: ({type(ts)})")

    try:
        _ts: datetime = datetime.utcfromtimestamp(ts).strftime(TS_FORMAT)
        
        return  _ts
    except Exception as exc:
        msg = Exception(f"Unhandled exception converting input timestamp '{ts}' to Python datetime. Details: {exc}")
        print(f"[ERROR] {msg}")
        
        raise msg

def scan_dir(
    p: t.Union[str, Path] = None, follow_symlinks: bool = False
) -> t.Generator[Path, None, None]:
    """Recursively yield DirEntry objects for a given path.

    Params:
        p (str | Path): A path to scan. Will be converted to a Path object.
        follow_symlinks (bool): If `True`, recursive scans will follow symlinked dirs.

    Usage:
        - Create a variable, i.e. 'all_entries'.
        - Define as: `all_entries = list(scan_dir(some/path))`

    Returns:
        (Generator[Path, None, None]): Yields files found during scan.
    """
    assert p is not None, ValueError("p cannot be None")
    assert isinstance(p, str) or isinstance(p, Path), TypeError(
        f"p must be of type str or Path. Got type: ({type(p)})"
    )
    if isinstance(p, str):
        p: Path = Path(p)

    if not p.exists():
        print(f"[ERROR] Could not find path: {p}")
        return
    if p.is_file():
        print(f"[ERROR] '{p}' is a file. Scan dir should be a Path object.")
        return

    try:
        for entry in os.scandir(p):
            if entry.is_dir(follow_symlinks=follow_symlinks):
                ## Recurse into subdirectories
                yield from scan_dir(entry.path)

            else:
                ## Yield file as a Path object
                yield Path(entry.path)
    except Exception as exc:
        msg = Exception(f"Unhandled exception scanning path '{p}'. Details: {exc}")
        print(f"[ERROR] {msg}")

def clean_dir(p: t.Union[str, Path] = None, follow_symlinks: bool = False, dry_run: bool = False, keep_backups: int = KEEP_BACKUPS):
    assert p is not None, ValueError("Missing an input path to clean")
    assert isinstance(p, str) or isinstance(p, Path), TypeError(f"Input path must be of type str or Path. Got type: ({type(p)})")
    if isinstance(p, str):
        p: Path = Path(p)
    assert p.exists(), FileNotFoundError(f"Could not find path: '{p}'")

    print(f"Scanning for files in path '{p}'")
    try:
        _files = list(scan_dir(p=p))
        print(f"Found [{len(_files)}] file(s) in path '{p}'")
    except Exception as exc:
        msg = Exception(f"Unhandled exception getting list of files in path: '{p}'. Details: {exc}")
        print(f"[ERROR] {msg}")
        
        raise msg
    
    file_objs: list[ScannedFile] = []
    
    for f in _files:
        f_obj: ScannedFile = ScannedFile(path=f, created_time=f.stat().st_ctime)
        file_objs.append(f_obj)
        
    file_objs.sort(key=lambda x: x.created_time)
    
    if not len(file_objs) > keep_backups:
        print(f"Backup count [{len(file_objs)}] is less than the backup limit of [{keep_backups}]. Skipping cleanup.")
        
        return file_objs

    print(f"Backup count [{len(file_objs)}] is equal to or greater than the backup limit of [{keep_backups}]")
    
    rm_backups: list[ScannedFile] = file_objs[0:-keep_backups]
    
    print(f"Removing [{len(rm_backups)}] backup(s) to bring backup count under threshold")
    
    for f in rm_backups:
        if f.path.is_file():
            if not dry_run:
                try:
                    f.path.unlink()
                    print(f"[SUCCESS] Removed file '{f.path}'")
                except Exception as exc:
                    msg = Exception(f"Unable to remove file '{f.path}'. Details: {exc}")
                    print(f"[ERROR] {msg}")
                    
                    pass
            else:
                print(f"[DRY RUN] Would remove file: '{f.path}'")
                pass

        else:
            if not dry_run:
                try:
                    shutil.rmtree(path=f.path)
                    print(f"[SUCCESS] Removed directory '{f.path}'.")
                except Exception as exc:
                    msg = Exception(f"Unable to remove file '{f.path}'. Details: {exc}")
                    print(f"[ERROR] {msg}")
                    
                    pass
            else:
                print(f"[DRY_RUN] Would remove directory: '{f.path}'")
                pass

def main(dry_run: bool = False):
    cleaned_db_backups = clean_dir(p=DB_BACKUP_DIR, dry_run=dry_run)
    cleaned_paperless_data_backups = clean_dir(p=PAPERLESS_DATA_BACKUP_DIR, dry_run=dry_run)
    cleaned_paperless_media_backups = clean_dir(p=PAPERLESS_MEDIA_BACKUP_DIR, dry_run=dry_run)
    
if __name__ == "__main__":
    print(f"Backup path: {BACKUP_DIR}")
    
    DRY_RUN: bool = False

    main(dry_run=DRY_RUN)
    
    
