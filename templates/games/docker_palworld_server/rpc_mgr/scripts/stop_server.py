from rpc_mgr.core import setup
from rpc_mgr.client import PalworldRPCController

from loguru import logger as log

if __name__ == "__main__":
    setup.setup_logging(log_level="DEBUG", colorize=True)
    server_mgr = PalworldRPCController(container_name="palworld-server")
    server_mgr.shutdown_server(ignore_online=True)