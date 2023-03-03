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
)


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


def debug_print_server_dirs(server_dirs: List[MCServer] = server_dirs):
    """
    Loop through server_dirs input, debug print chosen class values.
    """

    ## Loop list of server_dirs
    for server_dir in server_dirs:
        print(
            f"[DEBUG] Server directory '{server_dir.name}'\n\tClass object: [{server_dir}]\n\tBase path: {server_dir.base_dir}\n\tWhitelist file: {server_dir.whitelist_file}\n\tDocker Compose file: {server_dir.compose_file}Whitelist: {server_dir.whitelist}\n\tContents: {server_dir.whitelist.data}"
        )


def main():
    debug_print_server_dirs()


if __name__ == "__main__":
    main()
