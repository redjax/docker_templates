from __future__ import annotations

from rpc_mgr.client import PalworldRPCController
from rpc_mgr.core.setup import setup_logging

from loguru import logger as log

if __name__ == "__main__":
    setup_logging(log_level="DEBUG", colorize=True)
    
    server_mgr = PalworldRPCController(container_name="palworld-server")
    
    # server_mgr.save(announce_save=True)
    server_mgr.shutdown_server(ignore_online=True, countdown=60)
    # server_mgr.start_server()