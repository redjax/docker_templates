from pathlib import Path
from typing import Dict, List

import json

from lib.models import (
    base_server_dir,
    ignore_dirs,
    all_server_dirs,
    MCServer,
    WhitelistFile,
    MCDockerCommand,
    MCDockerCommandGroup,
)

_player: str = "r3djak"
_item: str = "chest"
_quant: int = 1


def get_server_objs(scan_dir: str = base_server_dir):
    ## A list of ServerDir class objects
    server_dirs: List[MCServer] = []

    ## Loop over directories in base_server_dir
    for found_dir in Path(base_server_dir).iterdir():
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


def debug_print_server_dirs(server_dirs: List[MCServer] = None):
    """
    Loop through server_dirs input, debug print chosen class values.
    """

    ## Loop list of server_dirs
    for server_dir in server_dirs:
        print(
            f"[DEBUG] Server directory '{server_dir.name}'\n\tClass object: [{server_dir}]\n\tBase path: {server_dir.base_dir}\n\tWhitelist file: {server_dir.whitelist_file}\n\tDocker Compose file: {server_dir.compose_file}Whitelist: {server_dir.whitelist}\n\tContents: {server_dir.whitelist.data}"
        )


def test_give_cmd(
    server_obj: MCServer = None,
    container: str = None,
    player: str = _player,
    item: str = _item,
    quantity: int = _quant,
):
    print(f"Giving [{item} of {quantity}] to [{player}] on [{server_obj.name}]")

    _test_cmd = f"give {player} {item} {quantity}"

    cmd_obj = MCDockerCommand(
        server=server_obj, container_name=container, cmd=_test_cmd
    )

    return cmd_obj


def main():
    server_dirs = get_server_objs()
    # debug_print_server_dirs(server_dirs=server_dirs)

    test_docker_cmd = test_give_cmd(server_obj=server_dirs[1], container="mc-server")

    test_docker_cmd.exec_cmd()


if __name__ == "__main__":
    main()
