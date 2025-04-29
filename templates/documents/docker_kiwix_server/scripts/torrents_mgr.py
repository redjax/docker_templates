# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "transmission-rpc",
# ]
# ///

import logging
import os
import argparse
from dataclasses import dataclass, field
from transmission_rpc import Client

log = logging.getLogger(__name__)


## Options: WARNING, INFO, DEBUG, ERROR, CRITICAL
LOG_LEVEL: str = os.environ.get("LOG_LEVEL", "DEBUG")


@dataclass
class TransmissionSettings:
    host: str
    port: int
    username: str | None = field(default=None)
    password: str | None = field(default=None, repr=False)
    

def parse_args():
    parser = argparse.ArgumentParser("transmission_mgr", description="Manage Transmission remote.")
    
    parser.add_argument("--debug", action="store_true", help="Enable debug logging")
    parser.add_argument("--host", type=str, default="localhost", help="The IP or FQDN of your Transmission server")
    parser.add_argument("--port", type=str, default=9091, help="The port of your Transmission server")
    parser.add_argument("--username", type=str, default=None, help="The username of your Transmission server")
    parser.add_argument("--password", type=str, default=None, help="The password of your Transmission server")
    
    args = parser.parse_args()
    
    return args
    
    
def setup_logging(
    log_level: str = "INFO",
    log_fmt: str = "%(asctime)s | [%(levelname)s] :: %(message)s",
    debug_log_fmt: str = "%(asctime)s | [%(levelname)s] | %(name)s:%(lineno)d :: %(message)s",
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


def get_transmission_client(host: str, port: int, username: str | None = None, password: str | None = None):
    try:
        client: Client = Client(
            host=host,
            port=port,
            username=username,
            password=password
        )
    except Exception as exc:
        log.error(f"Error intializing Transmission RPC client. Details: {exc}")
        raise
    
    return client


def remove_finished_torrents(client: Client):
    ## Fetch all torrents
    log.info("Fetching torrents from remote Transmission server ...")
    try:
        torrents = client.get_torrents()
    except Exception as exc:
        log.error(f"Error fetching torrents. Details: {exc}")
        raise
    
    if not torrents:
        log.info("No torrents found.")
        return []
    
    log.info(f"Fetched [{len(torrents)}] torrent(s)")
    
    removed_torrents = []

    log.info("Removing finished torrents (status=seeding or status=stopped and progress=100%) ...")
    ## Iterate and remove finished torrents
    for torrent in torrents:
        ## Check if torrent is finished (downloaded and not actively downloading)
        if torrent.status in ['seeding', 'stopped'] and torrent.progress == 100:
            log.debug(f"Removing finished torrent: {torrent.name}")
            try:
                client.remove_torrent(torrent.id, delete_data=False)
                removed_torrents.append(torrent.name)
            except Exception as exc:
                log.error(f"Error removing torrent: {torrent.name}. Details: {exc}")
                continue
    
    if len(removed_torrents) == 0:
        log.info("No torrents were removed.")
    else:
        log.info(f"Removed [{len(removed_torrents)}] torrent(s)")

    return removed_torrents
        
def main(transmission_host: str, transmission_port: int, transmission_username: str | None = None, transmission_password: str | None = None):
    if not all([transmission_host, transmission_port]):
        raise ValueError("All required Transmission settings must be provided. You must pass at least a host and port. If your Transmission instance uses basic authentication, you must also pass the username and password.")

    transmission_settings: TransmissionSettings = TransmissionSettings(host=transmission_host, port=transmission_port, username=transmission_username, password=transmission_password)
    log.debug(f"Transmission settings: {transmission_settings}")
    
    try:
        transmission_client: Client = get_transmission_client(host=transmission_host, port=transmission_port, username=transmission_username, password=transmission_password)
    except Exception as exc:
        log.error(f"Error intializing Transmission RPC client. Details: {exc}")
        raise
    
    try:
        removed_torrents = remove_finished_torrents(client=transmission_client)
    except Exception as exc:
        log.error(f"Error removing finished torrents. Details: {exc}")
        raise


if __name__ == "__main__":
    args = parse_args()
    
    if args.debug:
        log_level = "DEBUG"
    else:
        log_level = os.environ.get("LOG_LEVEL", "INFO")
        
    setup_logging(log_level=log_level, silence_loggers=["urllib3", "urllib3.connectionpool"])
    
    log.debug(f"CLI args: {args}")
    
    _transmission_host = args.host
    if not _transmission_host:
        _transmission_host = os.environ.get("TRANSMISSION_HOST")
    _transmission_port = args.port
    if not _transmission_port:
        _transmission_port = os.environ.get("TRANSMISSION_PORT")
    _transmission_username = args.username
    if not _transmission_username:
        _transmission_username = os.environ.get("TRANSMISSION_USERNAME")
    _transmission_password = args.password
    if not _transmission_password:
        _transmission_password = os.environ.get("TRANSMISSION_PASSWORD")
        
    try:
        main(
            transmission_host=_transmission_host,
            transmission_port=int(_transmission_port),
            transmission_username=_transmission_username,
            transmission_password=_transmission_password,
        )
        exit(0)
    except Exception as exc:
        log.error(f"Error: {exc}")
        exit(1)
