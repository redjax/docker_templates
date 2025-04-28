import logging
import typing as t
from pathlib import Path
import os
import shutil

log = logging.getLogger(__name__)

## When True, env variables detected by the script will be printed
PRINT_ENV: bool = True
## Options: WARNING, INFO, DEBUG, ERROR, CRITICAL
LOG_LEVEL: str = "DEBUG"
## When True, user will be prompted before moving each file
PROMPT_BEFORE_MOVING: bool = False

## Kiwix root path
KIWIX_ZIM_DIR: str = os.environ["KIWIX_DATA_DIR"] or "./data/kiwix"

## Transmission root path
TRANSMISSION_DIR: str = (
    os.environ["TRANSMISSION_TORRENT_DIR"] or "./data/transmission/torrent"
)
## Transmission incomplete downloads path
TRANSMISSION_INCOMPLETE_DIR: str = f"{TRANSMISSION_DIR}/incomplete"
## Transmission completed downloads path
TRANSMISSION_COMPLETE_DIR: str = f"{TRANSMISSION_DIR}/complete"


def setup_logging(
    log_level: str = "INFO",
    log_fmt: str = "%(levelname)s | [%(asctime)s] |> %(message)s",
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
    logging.basicConfig(level=log_level, format=log_fmt, datefmt=datefmt)

    if silence_loggers:
        for _logger in silence_loggers:
            logging.getLogger(_logger).setLevel("WARNING")


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


def print_script_env() -> None:
    print(
        f"""
[Script Environment]
  - PROMPT_BEFORE_MOVING={PROMPT_BEFORE_MOVING}
  - [Exists: {path_exists(KIWIX_ZIM_DIR)}] KIWIX_ZIM_DIR={KIWIX_ZIM_DIR}
  - [Exists: {path_exists(TRANSMISSION_DIR)}] TRANSMISSION_DIR={TRANSMISSION_DIR}
  - [Exists: {path_exists(TRANSMISSION_INCOMPLETE_DIR)}] TRANSMISSION_INCOMPLETE_DIR={TRANSMISSION_INCOMPLETE_DIR}
  - [Exists: {path_exists(TRANSMISSION_COMPLETE_DIR)}] TRANSMISSION_COMPLETE_DIR={TRANSMISSION_COMPLETE_DIR}
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
    completed_torrents_path: t.Union[str, Path] = TRANSMISSION_COMPLETE_DIR,
    incomplete_torrents_path: t.Union[str, Path] = TRANSMISSION_INCOMPLETE_DIR,
    kiwix_zim_path: t.Union[str, Path] = KIWIX_ZIM_DIR,
    kiwix_zim_live_path: t.Union[str, Path] = KIWIX_ZIM_DIR,
    create_paths_if_not_exist: bool = False,
    prompt_before_move: bool = False,
    print_script_environment: bool = False
):
    if print_script_environment:
        print_script_env()

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
        raise ValueError("Complete torrents list is None/empty.")
    log.info(f"Found [{len(completed_torrents)}] completed torrent(s).")
    log.debug(f"Complete torrents: {completed_torrents}")

    try:
        mv_successes, mv_errors, mv_skipped = move_completed(
            completed_files=completed_torrents, target_dir=kiwix_zim_live_path, prompt_confirm=prompt_before_move
        )
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
    setup_logging(log_level=LOG_LEVEL or "INFO")

    main(
        completed_torrents_path=TRANSMISSION_COMPLETE_DIR,
        incomplete_torrents_path=TRANSMISSION_INCOMPLETE_DIR,
        kiwix_zim_path=KIWIX_ZIM_DIR,
        kiwix_zim_live_path=KIWIX_ZIM_DIR,
        create_paths_if_not_exist=False,
        prompt_before_move=PROMPT_BEFORE_MOVING,
        print_script_environment=PRINT_ENV
    )
