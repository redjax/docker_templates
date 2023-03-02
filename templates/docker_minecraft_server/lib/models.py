from pathlib import Path
from typing import Dict, List

import json

from lib.utils import whitelist_data

base_server_dir = "servers"

ignore_dirs = ["_templates"]

all_server_dirs = Path(base_server_dir).rglob("*")


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

    @property
    def parts(self) -> List:
        """
        Return list of pathlib.Path parts. Access root/base dir with self.parts[0],
        the server dir with self.parts[1], etc.

        The value simply references the __init__ function's path_parts param.
        """
        _parts = self.rel_path

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
                path=self.whitelist_file, data=whitelist_data(self.whitelist_file)
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
