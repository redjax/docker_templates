import logging
import typing as t
from pathlib import Path
import os
import shutil
import argparse
import time

log = logging.getLogger(__name__)

## Options: WARNING, INFO, DEBUG, ERROR, CRITICAL
LOG_LEVEL: str = os.environ.get("LOG_LEVEL", "DEBUG")

## Kiwix root path
DEFAULT_KIWIX_ZIM_DIR: str = os.environ.get("KIWIX_DATA_DIR","./data/kiwix")

## Transmission root path
DEFAULT_TRANSMISSION_DIR: str = (
    os.environ.get("TRANSMISSION_TORRENT_DIR", "./data/transmission/torrent")
)

IGNORE_PATTERNS: list[str] = ["*.part"]

class EmptyZimDirectoryException(Exception):
    pass


def parse_args():
    parser = argparse.ArgumentParser(description="Script to move completed zim files.")
    
    parser.add_argument("-z", "--zim-dir", type=str, default=DEFAULT_KIWIX_ZIM_DIR, help="Kiwix zim directory")
    parser.add_argument("-t", "--torrent-dir", type=str, default=DEFAULT_TRANSMISSION_DIR, help="Transmission torrent directory")
    parser.add_argument("-p", "--prompt", action="store_true", help="Prompt before moving each file")
    parser.add_argument("--print-env", action="store_true", help="Print script environment")
    parser.add_argument("-d", "--debug", action="store_true", help="Enable debug logging")
    parser.add_argument("-l", "--loop", action="store_true", help="Run script on a loop")
    parser.add_argument("-s", "--loop-sleep", type=int, default=60, help="Loop sleep time in seconds")
    parser.add_argument("-i", "--ignore", nargs="+", default=IGNORE_PATTERNS, help="Path patterns to ignore")
    
    args = parser.parse_args()
    
    return args


def setup_logging(
    log_level: str = "INFO",
    log_fmt: str = "%(asctime)s | [%(levelname)s] :: %(message)s",
    debug_log_fmt: str = "%(asctime)s | [%(levelname)s] | %(filename)s:%(lineno)d :: %(message)s",
    datefmt: str = "%Y-%m-%d_%H:%M:%S",
    silence_loggers: list[str] | None = [],
) -> None:
    """Setup logging for the application.

    Usage:
        Somewhere high in your project's execution, ideally any entrypoint like `wsgi.py` for Django, or your
        app's `main.py`/`__main__.py` file, call this function to configure logging for the whole app.

        Then in each module/script, simply import logging and create a variable `log = logging.getLogger(__name__)`
        to setup logging for that module.

    Params:
        log_level (str): The logging level string, i.e. "WARNING", "INFO", "DEBUG", "ERROR", "CRITICAL"
        log_fmt (str): The logging format string.
        datefmt (str): The format for datetimes in the logging string.
        silence_loggers (list[str]): A list of logger names to "disable" by setting their logLevel to "WARNING".
            Use this for any 3rd party modules, or dynamically load a list of loggers to silence from the environment.
    """
    log_level: str = log_level.upper()
    
    _fmt = debug_log_fmt if log_level == "DEBUG" else log_fmt
    
    logging.basicConfig(level=log_level, format=_fmt, datefmt=datefmt)

    if silence_loggers:
        for _logger in silence_loggers:
            logging.getLogger(_logger).disabled = True


def str_to_path(p: t.Union[str, Path]) -> Path:
    if not p:
        raise ValueError("Missing a path to convert to pathlib.Path.")

    if isinstance(p, Path):
        return p
    else:
        return Path(str(p)).expanduser() if "~" in str(p) else Path(str(p))


def path_exists(p: t.Union[str, Path], create_path: bool = False) -> bool:
    if not p:
        raise ValueError("Missing a path to check existence of.")

    p: Path = str_to_path(p)

    if not create_path:
        return p.exists()
    else:
        try:
            p.mkdir(parents=True, exist_ok=True)
        except Exception as exc:
            msg = f"({type(exc)}) Error creating path '{p}'. Details: {exc}"
            log.error(msg)

        return p


def print_script_env(prompt: bool, transmission_dir: str = DEFAULT_TRANSMISSION_DIR, kiwix_zim_dir: str = DEFAULT_KIWIX_ZIM_DIR) -> None:
    incomplete_dir = f"{transmission_dir}/incomplete"
    complete_dir = f"{transmission_dir}/complete"

    print(
        f"""
[Script Environment]
  - PROMPT_BEFORE_MOVING={prompt}
  - [Exists: {path_exists(kiwix_zim_dir)}] KIWIX_ZIM_DIR={kiwix_zim_dir}
  - [Exists: {path_exists(transmission_dir)}] TRANSMISSION_DIR={transmission_dir}
  - [Exists: {path_exists(incomplete_dir)}] TRANSMISSION_INCOMPLETE_DIR={incomplete_dir}
  - [Exists: {path_exists(complete_dir)}] TRANSMISSION_COMPLETE_DIR={complete_dir}
"""
    )


def scan_completed(completed_path: t.Union[str, Path]):
    if not completed_path:
        raise ValueError("Missing a path to completed torrent downloads.")

    completed_path: Path = str_to_path(completed_path)

    _files: list[Path] = list(completed_path.rglob("**/*"))

    return _files


def move_completed(
    completed_files: list[Path],
    target_dir: t.Union[str, Path],
    ignore_patterns: list[str],
    prompt_confirm: bool = False,
) -> t.Tuple[list[Path] | None, list[Path] | None, list[Path] | None] | None:
    if not completed_files:
        raise ValueError("Missing list of completed files to move.")
    if not target_dir:
        raise ValueError("Missing destination path to move completed files to.")

    target_dir: Path = str_to_path(target_dir)

    successes: list[Path] | None = []
    errors: list[Path] | None = []
    skipped: list[Path] | None = []

    log.info(f"Moving [{len(completed_files)}] to path: {target_dir}\n")

    for f in completed_files:
        ## Check if any part of file is in ignored patterns IGNORE_PATTERNS
        if any(f.match(pattern) for pattern in ignore_patterns):
            log.debug(f"Skipping ignored item: {f.name}")
            continue
        
        move_file: bool = True
        target_path: Path = target_dir / f.name

        if prompt_confirm:
            while True:
                mv_choice = input(f"[PROMPT] Move file '{f}' to {target_path} (Y/N)? ")
                match mv_choice.lower():
                    case "y" | "Y":
                        move_file = True
                        break
                    case "n" | "N":
                        move_file = False
                        break
                    case _:
                        log.warning(f"Invalid choice: {mv_choice}. Must by 'Y' or 'N'.")

        if move_file:
            log.info(f"Moving file '{f}' to '{target_path}'")
            try:
                shutil.move(src=f, dst=target_path)
                successes.append(f)
            except PermissionError:
                log.error(f"Permission denied moving file '{f}' to path '{target_path}'.")
                errors.append(f)
            except Exception as exc:
                msg = f"({type(exc)}) Error moving file '{f}'. Details: {exc}"
                log.error(msg)
                errors.append(f)

                continue
        else:
            log.warning(f"Skipping file: {f}")
            skipped.append(f)
            continue

    return successes, errors, skipped


def main(
    transmission_dir: t.Union[str, Path],
    kiwix_zim_path: t.Union[str, Path],
    kiwix_zim_live_path: t.Union[str, Path],
    ignore_patterns: list[str],
    create_paths_if_not_exist: bool = False,
    prompt_before_move: bool = False,
    print_script_environment: bool = False
):
    ## Transmission incomplete downloads path
    incomplete_torrents_path: str = f"{transmission_dir}/incomplete"
    ## Transmission completed downloads path
    completed_torrents_path: str = f"{transmission_dir}/complete"
    
    if print_script_environment:
        print_script_env(prompt=prompt_before_move, transmission_dir=transmission_dir, kiwix_zim_dir=kiwix_zim_path)
        exit(0)

    completed_torrents_path: Path = str_to_path(completed_torrents_path)
    incomplete_torrents_path: Path = str_to_path(incomplete_torrents_path)
    kiwix_zim_path: Path = str_to_path(kiwix_zim_path)
    kiwix_zim_live_path: Path = str_to_path(kiwix_zim_live_path)

    for p in [
        completed_torrents_path,
        incomplete_torrents_path,
        kiwix_zim_path,
        kiwix_zim_live_path,
    ]:
        path_exists(p, create_path=create_paths_if_not_exist)

    try:
        completed_torrents: list[Path] = scan_completed(
            completed_path=completed_torrents_path
        )
    except PermissionError:
        msg = f"Permission error scanning completed torrents in path '{completed_torrents_path}'."
        raise
    except Exception as exc:
        msg = f"({type(exc)}) Error scanning for completed torrents in path '{completed_torrents_path}'. Details: {exc}"
        log.error(msg)

        raise exc

    if not completed_torrents:
        raise EmptyZimDirectoryException(f"No files were found in path: {kiwix_zim_live_path}.")
    log.info(f"Found [{len(completed_torrents)}] completed torrent(s).")
    log.debug(f"Complete torrents: {completed_torrents}")

    try:
        mv_successes, mv_errors, mv_skipped = move_completed(
            completed_files=completed_torrents, target_dir=kiwix_zim_live_path, prompt_confirm=prompt_before_move, ignore_patterns=ignore_patterns
        )
    except EmptyZimDirectoryException as no_files_err:
        log.warning(f"No files were found in path: {kiwix_zim_live_path}")
        raise
    except Exception as exc:
        msg = f"({type(exc)}) Error moving some/all completed torrents to Kiwix ZIM directory: {kiwix_zim_live_path}. Details: {exc}"
        log.error(msg)

        raise exc

    log.info(
        f"Moved [{len(mv_successes)}] file(s) successfully. Errored moving [{len(mv_errors)}] file(s)."
    )
    if mv_skipped:
        log.info(f"Skipped [{len(mv_skipped)}] file(s)")


if __name__ == "__main__":
    args = parse_args()
    
    if args.debug:
        log_level = "DEBUG"
    else:
        log_level = os.environ.get("LOG_LEVEL", "INFO")
        
    setup_logging(log_level=log_level)
    
    log.debug(f"CLI args: {args}")

    if args.loop:
        log.info("Starting zim move script on a loop, sleep for [{} seconds]".format(args.loop_sleep))
        while True:
            try:
                main(
                    transmission_dir=args.torrent_dir or DEFAULT_TRANSMISSION_DIR,
                    kiwix_zim_path=args.zim_dir or DEFAULT_KIWIX_ZIM_DIR,
                    kiwix_zim_live_path=args.zim_dir or DEFAULT_KIWIX_ZIM_DIR,
                    create_paths_if_not_exist=False,
                    prompt_before_move=args.prompt,
                    print_script_environment=args.print_env,
                    ignore_patterns=args.ignore or IGNORE_PATTERNS
                )
            except EmptyZimDirectoryException as no_files_err:
                log.warning(no_files_err)
                pass
            except Exception as exc:
                log.error(f"Error: {exc}")
                exit(1)
                
            log.info(f"Sleeping for [{args.loop_sleep}] second(s) ...")
            
            time.sleep(args.loop_sleep)

    else:
        try:
            main(
                transmission_dir=args.torrent_dir or DEFAULT_TRANSMISSION_DIR,
                kiwix_zim_path=args.zim_dir or DEFAULT_KIWIX_ZIM_DIR,
                kiwix_zim_live_path=args.zim_dir or DEFAULT_KIWIX_ZIM_DIR,
                create_paths_if_not_exist=False,
                prompt_before_move=args.prompt,
                print_script_environment=args.print_env,
                ignore_patterns=args.ignore or IGNORE_PATTERNS
            )
        except EmptyZimDirectoryException as no_files_err:
            exit(0)
        except Exception as exc:
            log.error(f"Error: {exc}")
            exit(1)
