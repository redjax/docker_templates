from loguru import logger as log

from rpc_mgr.core import setup
from rpc_mgr.client import PalworldRPCController

import schedule
import time
from halo import Halo


def return_palworld_rpc_controller(container_name: str, debug: bool = False) -> PalworldRPCController:
    """Initialize & return a PalworldRPCController class.
    
    Params:
        container_name (str): Name of the palworld server container.
        debug (bool): If True, debug logging will be enabled.
    
    Returns:
        PalworldRPCController: An instance of the PalworldRPCController class.

    """
    controller: PalworldRPCController = PalworldRPCController(container_name=container_name, debug=debug)
    
    return controller


def check_online_players(container_name: str, debug: bool = False):
    rpc_client: PalworldRPCController = return_palworld_rpc_controller(container_name=container_name, debug=debug)
    
    log.info("Checking for online players")
    try:
        online_players: list = rpc_client.get_players()
    except Exception as exc:
        msg = f"({type(exc)}) Error getting list of online players. Details: {exc}"
        log.error(msg)
        
        return
    
    if online_players is None or len(online_players) == 0:
        log.info("No players online.")
        return
    
    log.info(f"[{len(online_players)}] player(s) online")
    log.debug(f"Online players: {online_players}")
    
    return online_players
    

def start_server(container_name: str, debug: bool = False) -> bool:
    rpc_client: PalworldRPCController = return_palworld_rpc_controller(container_name=container_name, debug=debug)
    
    ## Attempt a docker command to see if the container is online
    log.debug("Check if server is already online")
    try:
        _up_test = rpc_client.update_server()
        log.info("Server is already online.")
        
        
        return
    except Exception as exc:
        log.info("Server is not online. Continuing with startup sequence.")
    
    log.info("Starting server")
    try:
        rpc_client.start_server()
        
        return True
    except Exception as exc:
        msg = f"({type(exc)}) Error starting server. Details: {exc}"
        log.error(msg)
        
        return False
    
    
def stop_server(container_name: str, debug: bool = False) -> bool:    
    rpc_client: PalworldRPCController = return_palworld_rpc_controller(container_name=container_name, debug=debug)
    
    log.info("Shutting down server if no players online.")

    try:
        online_players = rpc_client.get_players()
    except Exception as exc:
        msg = f"({type(exc)}) Error getting list of online players. Continuing with shutdown sequence. Details: {exc}"
        log.error(msg)
        
        raise exc
    
    if online_players is None or len(online_players) == 0:
        log.info("No players online. Shutting down server.")
    
        try:
            rpc_client.shutdown_server(countdown=0)
            
            return True
        except Exception as exc:
            msg = f"({type(exc)}) Error shutting down server. Details: {exc}"
            log.error(msg)
            
            return
    else:
        log.info(f"[{len(online_players)}] player(s) online. Skipping shutdown.")
        return


def server_sleep_schedule(container_name: str, debug: bool = False) -> bool:
    ## Start the server
    #  Set to 241 seconds to avoid collisions with shutdown schedule
    
    spinner = Halo(text="Running server sleep schedule", spinner="dots" )
    try:
        schedule.every(241).seconds.do(start_server, container_name=container_name, debug=debug)
    except Exception as exc:
        msg = f"({type(exc)}) Error running start_server scheduled task. Details: {exc}"
        log.error(msg)
        
        raise exc

    ## Stop the server
    try:
        schedule.every(5).minutes.do(stop_server, container_name=container_name, debug=debug)
    except Exception as exc:
        msg = f"({type(exc)}) Error running stop_server scheduled task. Details: {exc}"
        log.error(msg)
        
        raise exc
    
    ## Run scheduled tasks
    log.info("Starting server sleep schedule")
    try:
        while True:
            spinner.start(text="Running server sleep schedule")
            schedule.run_pending()
            time.sleep(1)
    except Exception as exc:
        spinner.stop()
        msg = f"({type(exc)}) Error running server sleep schedule. Details: {exc}"
        log.error(msg)
        
        raise exc
    except KeyboardInterrupt:
        spinner.stop()
        log.info("Keyboard interrupt detected. Stopping server sleep schedule.")
        return

    
if __name__ == "__main__":
    setup.setup_logging(log_level="DEBUG", colorize=True, add_error_file_logger=True, add_file_logger=True)
    
    server_sleep_schedule(container_name="palworld-server", debug=True)
