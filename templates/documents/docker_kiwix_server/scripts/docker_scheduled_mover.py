# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "schedule",
# ]
# ///

import argparse
import logging
import os
import time
import datetime as dt

from move_zims import main as move_zims_main
from move_zims import setup_logging, print_script_env
from move_zims import EmptyZimDirectoryException

log = logging.getLogger(__name__)

import schedule


def parse_args():
    parser = argparse.ArgumentParser("mover_scheduler", description="Scheduler entrypoint for moving completed Kiwix zim files.")
    
    parser.add_argument("-z", "--zim-dir", type=str, default="/kiwix-zims", help="Kiwix zim directory")
    parser.add_argument("-t", "--torrent-dir", type=str, default="/transmission-torrents", help="Transmission torrent directory")
    parser.add_argument("--print-env", action="store_true", help="Print script environment")
    parser.add_argument("-d", "--debug", action="store_true", help="Enable debug logging")
    parser.add_argument("-i", "--ignore", action="append", default=[], help="Path patterns to ignore")
    
    args = parser.parse_args()
    
    return args


def get_next_full_hour(now: dt.datetime | None = None) -> dt.datetime:
    """Return the next full hour datetime after `now`.

    If `now` is None, uses current time.
    Examples:
        1:30  -> 2:00
        8:16  -> 9:00
        23:59 -> next day 00:00
    """
    if now is None:
        now = dt.datetime.now()

    ## Replace minutes, seconds, microseconds with zero
    next_hour = now.replace(minute=0, second=0, microsecond=0) + dt.timedelta(hours=1)
    
    return next_hour


def job(
    transmission_dir: str,
    kiwix_zim_path: str,
    create_paths_if_not_exist: bool = False,
    print_script_environment: bool = False,
    ignore_patterns: list[str] = []
):
    try:
        move_zims_main(
            transmission_dir=transmission_dir,
            kiwix_zim_path=kiwix_zim_path,
            create_paths_if_not_exist=create_paths_if_not_exist,
            print_script_environment=print_script_environment,
            ignore_patterns=ignore_patterns
        )
    except EmptyZimDirectoryException:
        log.warning(EmptyZimDirectoryException(f"Kiwix zim directory is empty: {kiwix_zim_path}"))
        pass
    except Exception as exc:
        log.error(f"Error running scheduled script: {exc}")
        raise
    
    next_run = get_next_full_hour()
    log.info(f"Executed scheduled job. Next execution: {next_run}")
    

def main(
    transmission_dir: str,
    kiwix_zim_path: str,
    create_paths_if_not_exist: bool = False,
    print_script_environment: bool = False,
    ignore_patterns: list[str] = []
):
    log.info("Building schedule")
    try:
        schedule.every().hour.do(
            job,
            transmission_dir=transmission_dir,
            create_paths_if_not_exist=create_paths_if_not_exist,
            kiwix_zim_path=kiwix_zim_path,
            ignore_patterns=ignore_patterns,
            print_script_environment=print_script_environment
        )
    except Exception as exc:
        log.error(f"({type(exc)}) Error scheduling job: {exc}")
        raise
    
    
    log.info(f"Starting scheduler, running once per hour. Next run: {get_next_full_hour()}")
    while True:
        schedule.run_pending()        
        time.sleep(1)

if __name__ == "__main__":
    args = parse_args()
    
    if args.debug:
        log_level = "DEBUG"
    else:
        log_level = os.environ.get("LOG_LEVEL", "INFO")
        
    if not args.print_env:
        if os.environ.get("PRINT_ENV"):
            print_env = True
        else:
            print_env = False
    else:
        print_env = True
        
    setup_logging(log_level=log_level)
    
    log.debug(f"CLI args: {args}")
    
    _kiwix_zim_dir = args.zim_dir
    _transmission_dir = args.torrent_dir
    _ignore_patterns = args.ignore
    
    if args.print_env:
        print_script_env(
            prompt=False,
            transmission_dir=_transmission_dir,
            kiwix_zim_dir=_kiwix_zim_dir,
            ignore_patterns=_ignore_patterns
        )
    
    try:
        main(
            transmission_dir=_transmission_dir,
            kiwix_zim_path=_kiwix_zim_dir,
            create_paths_if_not_exist=False,
            print_script_environment=False,
            ignore_patterns=_ignore_patterns
        )
    except Exception as exc:
        log.error(f"Error running scheduled script: {exc}")
        exit(1)
    
    
