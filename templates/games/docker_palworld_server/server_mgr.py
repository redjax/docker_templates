import logging
import subprocess
import csv
import json
from pathlib import Path
from dataclasses import dataclass, field

log = logging.getLogger(__name__)

## Set the name of your palworld server container
PALWORLD_CONTAINER_NAME: str = "palworld"
## Enable/disable debugging
DEBUG: bool = True


def setup_logging(
    level: str = "INFO",
    fmt: str = "%(asctime)s [%(levelname)s] %(message)s",
    datefmt: str = "%Y-%m-%d %H:%M:%S",
):
    logging.basicConfig(level=level, format=fmt, datefmt=datefmt)


def format_seconds_to_timestr(seconds: int) -> str:
    """
    Converts an integer number of seconds into a human-readable duration string.

    Args:
        seconds (int): The number of seconds to convert.

    Returns:
        str: A human-readable duration string.
    """
    if seconds < 60:
        return f"{seconds} second{'s' if seconds != 1 else ''}"
    
    minutes, seconds = divmod(seconds, 60)
    if minutes < 60:
        return f"{minutes} minute{'s' if minutes != 1 else ''}"
    
    hours, minutes = divmod(minutes, 60)
    if hours < 24:
        return f"{hours} hour{'s' if hours != 1 else ''}"
    
    days, hours = divmod(hours, 24)
    if days < 7:
        return f"{days} day{'s' if days != 1 else ''}"
    
    weeks, days = divmod(days, 7)
    if weeks < 52:
        return f"{weeks} week{'s' if weeks != 1 else ''}"
    
    years, weeks = divmod(weeks, 52)
    return f"{years} year{'s' if years != 1 else ''}"


def execute_command(
    command: list[str],
    capture_output: bool = True,
    text: bool = True,
    check: bool = True,
) -> subprocess.CompletedProcess:
    """
    Execute a shell command and return the output.

    Params:
        command (list[str]): The command to execute as a list of strings.
        capture_output (bool): Whether to capture standard output and error.
        text (bool): If True, return the output as a string. If False, return bytes.
        check (bool): If True, raise CalledProcessError on a non-zero exit code.

    Returns:
        str: The command's standard output.

    Raises:
        subprocess.CalledProcessError: If the command fails and `check` is True.
    """
    log.info(f"Executing command: {' '.join(command)}")
    log.debug(f"Command ({type(command)}): {command}")

    try:
        result: subprocess.CompletedProcess = subprocess.run(
            command, capture_output=capture_output, text=text, check=check
        )
        log.debug(f"Command output: {result.stdout.strip()}")
        return result
    except subprocess.CalledProcessError as exc:
        log.error(
            f"Command failed with exit code {exc.returncode}. Error: {exc.stderr}"
        )
        raise


def get_players(server_name: str):
    log.info("Checking for online players...")

    command = [
        "docker",
        "compose",
        "exec",
        "-it",
        str(server_name),
        "rcon-cli",
        "ShowPlayers",
    ]
    try:
        result: subprocess.CompletedProcess = execute_command(command)
    except subprocess.CalledProcessError as cmd_exc:
        log.error(
            f"Error checking for online players. Is the server online? Is '{server_name}' the right name of the service in your Docker Compose file? Error details: {cmd_exc}"
        )

        raise cmd_exc

    except Exception as exc:
        msg = f"({type(exc)}) Error executing command. Details: {exc}"
        log.error(msg)

        raise exc
    
    if result.returncode != 0:
        log.error(f"Non-zero exit code: {result.returncode}")
        raise Exception(f"Shell exited with exit code: {result.returncode}")

    try:
        ## Split the output into lines
        lines = result.stdout.strip().splitlines()
    except Exception as exc:
        msg = f"({type(exc)}) Error parsing command output. Details: {exc}"
        log.error(msg)

        raise exc

    if not lines:
        log.warning("No shell output detected.")
        return

    ## Check if there are more lines than the header
    if len(lines) <= 1:
        log.debug("No players online.")
        return None

    ## Parse the CSV data
    csv_reader = csv.DictReader(lines)
    ## Convert each row to a dictionary
    players = [row for row in csv_reader]
    log.debug(f"Parsed player data ({type(players)}): {players}")

    return players


def announce(message: str, server_name: str):
    """Send a message to the server as the system user.
    
    Params:
        message (str): The message to send.
        server_name (str): The name of the server container.
    """
    log.debug(f"Broadcasting message: {message}")
    command = [
        "docker",
        "compose",
        "exec",
        "-it",
        str(server_name),
        "rcon-cli",
        f'Broadcast "{message}"',
    ]
    
    try:
        result = execute_command(command)
        log.debug(f"Announcement result: {result}")
    except Exception as exc:
        msg = f"({type(exc)}) Error executing server announcement command. Details: {exc}"
        log.error(msg)
        
        raise
    
    if result is None:
        log.error("Announcement failed.")
        return

    else:
        return True if result.returncode == 0 else False
    
    
def save(server_name: str, announce_save: bool = False):
    command = ["docker", "compose", "exec", "-it", str(server_name), "rcon-cli", "Save"]
    
    log.info("Saving the world...")
    try:
        result = execute_command(command)
    except Exception as exc:
        msg = f"({type(exc)}) Error executing save command. Details: {exc}"
        log.error(msg)
        
        raise
    
    if result is None:
        log.error("Save failed.")
        return False
    
    if result.returncode != 0:
        log.error(f"Non-zero exit code: {result.returncode}")
        return False
    
    log.info("World saved successfully.")
    if announce_save:
        try:
            announce(message="Progress saved.", server_name=server_name)
        except Exception as exc:
            msg = f"({type(exc)}) Error executing save announcement command. Details: {exc}"
            log.error(msg)
    
    return True


def shutdown_server(server_name: str):
    log.info("Shutting down the server...")
    command = ["docker", "compose", "down"]
    try:
        result = execute_command(command)
    except Exception as exc:
        msg = f"({type(exc)}) Error executing shutdown command. Details: {exc}"
        log.error(msg)
        
        raise
    
    if result is None:
        log.error("Shutdown failed.")
        return False
    
    if result.returncode != 0:
        log.error(f"Non-zero exit code: {result.returncode}")
        return False
    
    log.info("Server shut down successfully.")
    return True


def start_server(server_name: str):
    log.info("Starting the server...")
    command = ["docker", "compose", "up", "-d"]
    try:
        result = execute_command(command)
    except Exception as exc:
        msg = f"({type(exc)}) Error executing start command. Details: {exc}"
        log.error(msg)
        
        raise
    
    if result is None:
        log.error("Start failed.")
        return False
    
    if result.returncode != 0:
        log.error(f"Non-zero exit code: {result.returncode}")
        return False
    
    log.info("Server started successfully.")
    return True

def main(server_name: str):
    players: list[dict[str, str]] = get_players(server_name=server_name)
    
    if isinstance(players, list):
        ## Convert the list of dictionaries to JSON and print it
        players_json = json.dumps(players, indent=4)
        log.info(f"Players online:\n{players_json}")
        log.debug("1 or more players online. Skipping shutdown.")
        
        try:
            save(server_name=server_name, announce_save=True)
        except Exception as exc:
            log.error(exc)

    else:
        log.info("No players online.")
        
        try:
            save(server_name=server_name)
        except Exception as exc:
            msg = f"({type(exc)}) Error executing save command. Details: {exc}"
            log.error(msg)
        
        try:
            shutdown_server(server_name=server_name)
        except Exception as exc:
            log.error(exc)


if __name__ == "__main__":
    LOG_DEBUG_FMT: str = "%(asctime)s [%(levelname)s] [(%(name)s).%(funcName)s:%(lineno)d] %(message)s"
    LOG_SIMPLE_FMT: str = "%(asctime)s [%(levelname)s] %(message)s"
    
    LOG_FMT = LOG_DEBUG_FMT if DEBUG else LOG_SIMPLE_FMT
    LOG_LEVEL = "DEBUG" if DEBUG else "INFO"
    
    setup_logging(level=LOG_LEVEL, fmt=LOG_FMT)
    
    main(server_name=PALWORLD_CONTAINER_NAME)
