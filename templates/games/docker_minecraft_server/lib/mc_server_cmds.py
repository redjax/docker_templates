"""
Execute Minecraft server commands through a server's Docker-Compose file.
"""
from typing import List, Dict, Optional
from pathlib import Path

from lib.models import (
    base_server_dir,
    ignore_dirs,
    all_server_dirs,
    MCServer,
    MCDockerCommand,
)


def give_player_item(
    server_obj: MCServer = None,
    container_name: str = "mc-server",
    player_name: str = None,
    item_str: str = None,
    quantity: int = None,
) -> MCDockerCommand:
    """
    Returns: MCDockerCommand instance
        To run the command, use MCDockerCommand.exec_cmd()
    Parameters:
        - server_obj: An instance of MCServer. Used to cd into server's dir
            to run $ docker compose commands
        - container_name: Name of docker-compose container's service name.
            Default for new servers is 'mc-server'
        - player_name: Minecraft user's in-game character name.
            TODO: Load from whitelist object
        - item_str: Minecraft item's CLI-friendly name (i.e. "iron_nugget")
        - quantity: Number of item to give to player
    """

    print(
        f"[DEBUG] Giving [{item_str} of {quantity} to {player_name} on {server_obj.name}]"
    )

    _give_cmd = f"give {player_name} {item_str} {quantity}"

    cmd_obj = MCDockerCommand(
        server=server_obj, container_name=container_name, cmd=_give_cmd
    )

    return cmd_obj


def get_server_objs(scan_dir: str = base_server_dir):
    ## A list of ServerDir class objects
    server_dirs: List[MCServer] = []

    ## Loop over directories in base_server_dir
    for found_dir in Path(scan_dir).iterdir():
        ## Prepare path parts
        base_dir = Path(found_dir).parts[0]
        parent_root = Path(found_dir).parts[1]
        # path_parts = Path(found_dir).parts

        ## Instantiate ServerDir object
        # server_dir = ServerDir(base_dir=base_dir, name=parent_root, path_parts=path_parts)
        server_dir = MCServer(base_dir=base_dir, name=parent_root)

        ## Check if server_dir's name in ignore_dirs
        if server_dir.name not in ignore_dirs:
            ## Append server_dir to list if not in ignore_dirs
            server_dirs.append(server_dir)

    if server_dirs:
        return server_dirs

    else:
        return None
