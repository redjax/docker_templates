from pathlib import Path
from typing import Dict, List

import json

base_server_dir = "servers"

ignore_dirs = ["_templates"]

all_server_dirs = Path(base_server_dir).rglob("*")
# print(f"[DEBUG] all_server_dirs type: [{type(all_server_dirs)}]")


class ServerDirBase:
    """
    A directory in the $base_server_dir containing a Dockerized Minecraft server.

    Each server has a docker-compose.yml file and (optionally) a whitelist.
    """

    def __init__(
        self, base_dir: str = base_server_dir, name: str = None, path_parts: List = None
    ):
        self.base_dir = base_dir
        self.name = name
        self.path_parts = path_parts

    @property
    def parts(self) -> List:
        """
        Return list of pathlib.Path parts. Access root/base dir with self.parts[0],
        the server dir with self.parts[1], etc.

        The value simply references the __init__ function's path_parts param.
        """
        _parts = self.path_parts

        parts = []
        for part in _parts:
            if part not in parts:
                parts.append(part)

        return parts

    @property
    def rel_path(self):
        """
        Return string with relative path to server dir.

        Comprised of top 2 dirs in path (i.e. base_server_dir, server_dir.)
        """
        rel_path = f"{self.base_dir}/{self.name}"

        return rel_path

    @property
    def dict(self):
        self_dict = self.__dict__

        return self_dict


class WhitelistFileBase:
    def __init__(self, path: str = None, data: Dict = None):
        self.path = path
        self.data = data


class WhitelistFile(WhitelistFileBase):
    pass


class ServerDir(ServerDirBase):
    @property
    def whitelist_file(self) -> str:
        """
        Return a string that is the path to a server dir's whitelist.json file.
        """

        whitelist_path = f"{self.rel_path}/whitelist.json"

        return whitelist_path

    @property
    def whitelist(self):
        """
        Build a WhitelistFile class instance from data loaded in self.whitelist_file
        """

        if self.whitelist_file:
            whitelist = WhitelistFile(
                path=self.whitelist_file, data=self.whitelist_data()
            )

            return whitelist

    @property
    def compose_file(self):
        """
        Return a string to the server dir's docker-compose.yml file.
        """

        compose_file_path = f"{self.rel_path}/docker-compose.yml"

        if Path(compose_file_path).is_file():
            return compose_file_path

        else:
            return None

    def whitelist_data(self) -> Dict:
        """
        Return dict of whitelist file's JSON data.
        """

        ## Check if whitelist file exists
        if Path(self.whitelist_file).is_file():
            # print(f"Whitelist file for server [{self.name}] found at: {whitelist_path}")

            ## Open whitelist file
            read_whitelist = open(self.whitelist_file)
            ## Read contents into JSON
            whitelist_data = json.load(read_whitelist)

            ## Close file
            read_whitelist.close()

            ## Return dict of whitelist data
            return whitelist_data

        else:
            return None


## A list of ServerDir class objects
server_dirs: List[ServerDir] = []

## Loop over directories in base_server_dir
for found_dir in Path(base_server_dir).iterdir():
    ## Prepare path parts
    base_dir = Path(found_dir).parts[0]
    parent_root = Path(found_dir).parts[1]
    path_parts = Path(found_dir).parts

    ## Instantiate ServerDir object
    server_dir = ServerDir(base_dir=base_dir, name=parent_root, path_parts=path_parts)

    ## Check if server_dir's name in ignore_dirs
    if server_dir.name not in ignore_dirs:
        ## Append server_dir to list if not in ignore_dirs
        server_dirs.append(server_dir)

## Loop list of server_dirs
for server_dir in server_dirs:
    print(f"{server_dir.dict}")
    # print(f"Server directory: [{server_dir.name}]")
    # print(f"Server whitelistfile: {server_dir.whitelist_file}")
    # print(f"Server whitelist data: {server_dir.whitelist.data}")
    # print(f"Server docker-compose file: {server_dir.compose_file}")
