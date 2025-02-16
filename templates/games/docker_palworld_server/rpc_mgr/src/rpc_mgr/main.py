from __future__ import annotations

import csv
from dataclasses import dataclass, field
import json
from pathlib import Path
import subprocess

from rpc_mgr.core import setup
from rpc_mgr.client import PalworldRPCController

from loguru import logger as log

## Set the name of your palworld server container
PALWORLD_CONTAINER_NAME: str = "palworld"
## Enable/disable debugging
DEBUG: bool = True



def main(container_name: str):
    rpc_client = PalworldRPCController(container_name=container_name)
    players: list[dict[str, str]] = rpc_client.get_players(server_name=container_name)
    
    if isinstance(players, list):
        ## Convert the list of dictionaries to JSON and print it
        players_json = json.dumps(players, indent=4)
        log.info(f"Players online:\n{players_json}")
        log.debug("1 or more players online. Skipping shutdown.")
        
        try:
            rpc_client.save(announce_save=True)
        except Exception as exc:
            log.error(f"Error saving world: {exc}")

    else:
        log.info("No players online.")
        
        try:
            rpc_client.save()
        except Exception as exc:
            log.error(f"Error saving world: {exc}")
        
        try:
            rpc_client.shutdown_server(countdown=10)
        except Exception as exc:
            log.error(f"Error shutting down server: {exc}")


if __name__ == "__main__":
    LOG_DEBUG_FMT: str = "{time:YYYY-MM-DD HH:mm:ss} [{level}] ({module}.{function}:{line}) > {message}"
    LOG_SIMPLE_FMT: str = "{time:YYYY-MM-DD HH:mm:ss} [{level}] {message}"
    
    LOG_FMT = LOG_DEBUG_FMT if DEBUG else LOG_SIMPLE_FMT
    LOG_LEVEL = "DEBUG" if DEBUG else "INFO"
    
    setup.setup_logging(log_level=LOG_LEVEL, log_fmt=LOG_FMT)
    
    main(container_name=PALWORLD_CONTAINER_NAME)
