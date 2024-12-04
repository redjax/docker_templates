from rpc_mgr.core import setup
from rpc_mgr.client import PalworldRPCController

from loguru import logger as log

if __name__ == "__main__":
    setup.setup_logging(log_level="DEBUG", colorize=True, add_error_file_logger=True, add_file_logger=True)
    server_mgr = PalworldRPCController(container_name="palworld-server")
    online_players = server_mgr.get_players()
    
    if online_players:
        log.info(f"Online players ({len(online_players)}): {online_players}")
    else:
        log.info("No players online.")
