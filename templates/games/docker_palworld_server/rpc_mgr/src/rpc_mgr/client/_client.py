from __future__ import annotations

import csv
import json
from pathlib import Path
import subprocess
import time

from rpc_mgr.utils import str_utils

from .methods import execute_command

from loguru import logger as log

class PalworldRPCController:
    def __init__(self, container_name: str, debug: bool = False):
        self.container_name: str = container_name or "palworld"
        self.debug: bool = False
        
    def __enter__(self):
        return self

    def get_players(self) -> list[dict[str, str]] | None:
        """Fetches online players from the server."""
        log.info("Checking for online players...")
        command = [
            "docker",
            # "compose",
            "exec",
            "-it",
            self.container_name,
            "rcon-cli",
            "ShowPlayers",
        ]
        try:
            result = execute_command(command)
        except subprocess.CalledProcessError as exc:
            log.error(
                f"Error checking for online players: {exc}. Is the server running?"
            )
            raise exc
        if result.returncode != 0:
            raise Exception(f"Shell exited with code {result.returncode}")
        lines = result.stdout.strip().splitlines()
        if len(lines) <= 1:
            log.debug("No players online.")
            return None
        return [row for row in csv.DictReader(lines)]
    
    def announce(self, message: str) -> bool:
        """Sends a broadcast message to the server."""
        log.debug(f"Broadcasting message: {message}")
        command = [
            "docker",
            # "compose",
            "exec",
            "-it",
            self.container_name,
            "rcon-cli",
            f'Broadcast "{message}"',
        ]
        result = execute_command(command)
        return result.returncode == 0

    def save(self, announce_save: bool = False) -> bool:
        """Saves the game world."""
        log.info("Saving the world...")
        command = [
            "docker",
            # "compose",
            "exec",
            "-it",
            self.container_name,
            "rcon-cli",
            "Save",
        ]
        result = execute_command(command)
        if result.returncode != 0:
            return False
        log.info("World saved successfully.")
        if announce_save:
            self.announce("Progress saved.")
        return True

    def shutdown_server(self, countdown: int | None = 180, ignore_online: bool = False, force: bool = False) -> bool:
        """Shuts down the server."""
        log.info("Beginning server shutdown sequence")
        
        command = ["docker", "compose", "down"]
        players = self.get_players()
        
        if players is None or len(players)  == 0:
            self.save()
                
            log.info("No players are online, skipping countdown and shutting down immediately.")

            pass
            
        else:
            if not ignore_online:
                log.warning("Cannot shutdown server, players are online.")
                return False

            if force:
                log.warning("Forcing server shutdown.")
                try:
                    result = execute_command(command)
                except Exception as exc:
                    msg = f"({type(exc)}) Error executing shutdown command. Details: {exc}"
                    log.error(msg)
                    
                    raise exc

                if result is None:
                    log.error("Shutdown failed.")
                    
                    return False

                if result.returncode != 0:
                    log.error(f"Non-zero exit code: {result.returncode}")
                    
                    return False

                log.info("Server shut down successfully.")
                return True
            
            if countdown:
                log.debug(f"Shutting down Palworld server in {countdown} second(s)")
                self.announce(f"[WARNING] A shutdown is scheduled for the Palworld server. You will see a countdown as the shutdown approaches.")
                
                current_second: int = 0
                try:
                    while current_second < countdown:
                        remaining_time = countdown - current_second
                        
                        # Define the specific intervals to announce
                        alert_times = {30 * 60, 20 * 60, 15 * 60, 10 * 60, 5 * 60, 2 * 60, 1 * 60, 30}
                        
                        # If remaining time matches any of the alert times, send an announcement
                        if remaining_time in alert_times:
                            self.announce(
                                f"[WARNING] Server will shut down in {str_utils.format_seconds_to_timestr(seconds=remaining_time)}"
                            )
                            log.debug(f"Broadcasted shutdown countdown to server: {remaining_time} second(s)")
                        
                        time.sleep(1)
                        current_second += 1
                except KeyboardInterrupt:
                    log.warning("Shutdown cancelled by user.")
                    self.announce("Server shutdown cancelled. Server will stay online.")
                    
                    return False
            

        log.info("Shutting down the server...")
        result = execute_command(command)
            
        return result.returncode == 0

    def start_server(self) -> bool:
        """Starts the server."""
        log.info("Starting the server...")
        command = ["docker", "compose", "up", "-d"]
        result = execute_command(command)
        return result.returncode == 0
    
    
    def update_server(self) -> bool:
        raise NotImplementedError("Updating the server is not yet implemented.")
