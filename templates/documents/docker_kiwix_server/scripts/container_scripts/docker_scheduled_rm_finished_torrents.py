# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "schedule",
#     "transmission-rpc",
# ]
# ///

import argparse
import logging
import os
import time
import datetime as dt

from torrents_mgr import main as torrents_mgr_main
from torrents_mgr import setup_logging, test_transmission_connectivity

log = logging.getLogger(__name__)

import schedule


def parse_args():
    parser = argparse.ArgumentParser("torrent_mgr_scheduler", description="Scheduler entrypoint for removing completed torrent files.")
    
    parser.add_argument("-d", "--debug", action="store_true", help="Enable debug logging")
    parser.add_argument("--host", type=str, default=None, help="The IP or FQDN of your Transmission server")
    parser.add_argument("--port", type=str, default=None, help="The port of your Transmission server")
    parser.add_argument("--username", type=str, default=None, help="The username of your Transmission server")
    parser.add_argument("--password", type=str, default=None, help="The password of your Transmission server")
    
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


def get_next_quarter_hour(now: dt.datetime | None = None) -> dt.datetime:
    """Return the next quarter-hour datetime after `now`.

    If `now` is None, uses current time.
    Examples:
        1:07  -> 1:15
        8:16  -> 8:30
        23:59 -> next day 00:00
    """
    if now is None:
        now = dt.datetime.now()
    
    # Calculate minutes to add to reach the next quarter hour
    minute = now.minute
    next_quarter = ((minute // 15) + 1) * 15
    if next_quarter == 60:
        # Move to next hour
        next_time = now.replace(minute=0, second=0, microsecond=0) + dt.timedelta(hours=1)
    else:
        next_time = now.replace(minute=next_quarter, second=0, microsecond=0)
    
    return next_time


def job(
    transmission_host: str,
    transmission_port: str,
    transmission_username: str | None = None,
    transmission_password: str | None = None,
):
    try:
        torrents_mgr_main(
            transmission_host=transmission_host,
            transmission_port=transmission_port,
            transmission_username=transmission_username,
            transmission_password=transmission_password
        )
    except Exception as exc:
        log.error(f"Error running scheduled script: {exc}")
        raise
    
    next_run = get_next_quarter_hour()
    log.info(f"Executed scheduled job. Next execution: {next_run}")
    

def main(
    transmission_host: str,
    transmission_port: str,
    transmission_username: str | None = None,
    transmission_password: str | None = None,
):
    log.info("Building schedule")
    try:
        schedule.every(15).minutes.do(
            job,
            transmission_host=transmission_host,
            transmission_port=transmission_port,
            transmission_username=transmission_username,
            transmission_password=transmission_password
        )
    except Exception as exc:
        log.error(f"({type(exc)}) Error scheduling job: {exc}")
        raise
    
    log.info("Testing connectivity to Transmission server")
    try:
        connect_success = test_transmission_connectivity(host=transmission_host, port=transmission_port, username=transmission_username, password=transmission_password)
    except Exception as exc:
        log.error(f"Error connecting to Transmission server. Details: {exc}")
        raise
    
    log.info("Success connecting to Transmission server")    
    
    log.info(f"Starting scheduler, running once per hour. Next run: {get_next_quarter_hour()}")
    while True:
        schedule.run_pending()        
        time.sleep(1)

if __name__ == "__main__":
    args = parse_args()
    
    if args.debug:
        log_level = "DEBUG"
    else:
        log_level = os.environ.get("LOG_LEVEL", "INFO")
        
    setup_logging(log_level=log_level, silence_loggers=["urllib3.connectionpool"])
    
    log.debug(f"CLI args: {args}")
    
    _transmission_host = args.host
    _transmission_port = args.port
    _transmission_username = args.username
    _transmission_password = args.password
    
    if not _transmission_host:
        _transmission_host = os.environ.get("TRANSMISSION_HOST")
    if not _transmission_port:
        _transmission_port = os.environ.get("TRANSMISSION_PORT")
    if not _transmission_username:
        _transmission_username = os.environ.get("TRANSMISSION_USER")
    if not _transmission_password:
        _transmission_password = os.environ.get("TRANSMISSION_PASSWORD")
    
    try:
        main(
            transmission_host=_transmission_host,
            transmission_port=_transmission_port,
            transmission_username=_transmission_username,
            transmission_password=_transmission_password
        )
    except Exception as exc:
        log.error(f"Error running scheduled script: {exc}")
        exit(1)
    
    
