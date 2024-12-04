from loguru import logger as log

from rpc_mgr.core import setup
from rpc_mgr.tasks import server_sleep_schedule

if __name__ == "__main__":
    setup.setup_logging(log_level="INFO", colorize=True, add_error_file_logger=True, add_file_logger=True)
    
    server_sleep_schedule(container_name="palworld-server", debug=True)