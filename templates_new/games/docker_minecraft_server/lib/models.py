from pathlib import Path
from typing import Dict, List

import subprocess

import json

from lib.utils import whitelist_data

base_server_dir = "servers"

ignore_dirs = ["_templates"]

all_server_dirs = Path(base_server_dir).rglob("*")


class MCServerBase:
    """
    A directory in the $base_server_dir containing a Dockerized Minecraft server.

    Each server has a docker-compose.yml file and (optionally) a whitelist.
    """

    def __init__(
        self, base_dir: str = base_server_dir, name: str = None, path_parts: List = None
    ):
        self.base_dir = base_dir
        self.path_parts = path_parts
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
        rel_path = f"./{self.base_dir}/{self.name}"

        return rel_path


class WhitelistFileBase:
    def __init__(self, path: str = None, data: Dict = None):
        self.path = path
        self.data = data


class WhitelistFile(WhitelistFileBase):
    pass


class MCServer(MCServerBase):
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


class DockerCommandBase:
    def __init__(
        self,
        server: MCServer = None,
        container_name: str = "mc-server",
        cmd: str = None,
    ):
        self.server = server
        self.container_name = container_name
        self.cmd = cmd


class MCDockerCommand(DockerCommandBase):
    @property
    def cmd_base(self):
        cmd_base = f"docker compose exec -it {self.container_name} mc-send-to-console"

        return cmd_base

    @property
    def mc_cmd(self):
        mc_cmd = f"{self.cmd_base} {self.cmd}"

        return mc_cmd

    @property
    def cd_cmd(self):
        cd_cmd = f"cd {self.server.rel_path}"

        return cd_cmd

    def exec_cmd(self):
        cmd = self.mc_cmd.split(" ")

        while "" in cmd:
            cmd.remove("")

        print(f"Current cmd: {cmd}")

        result = subprocess.run(cmd, cwd=self.server.rel_path, stdout=subprocess.PIPE)
        _stdout = result.stdout.decode("utf-8")
        status_code = result.returncode

        if status_code != 0:
            return_obj = {
                "status": "non_zero_exit",
                "detail": {"return_code": status_code},
                "message": _stdout,
            }
        else:
            return_obj = {
                "status": "success",
                "detail": {"return_code": status_code},
                "message": None,
            }

        return return_obj


class MCDockerCommandGroupBase:
    def __init__(self):
        ...


class MCDockerCommandGroup(MCDockerCommandGroupBase):
    pass


class MCItemIDListBase:
    def __init__(self):
        ...


class MCItemIDList(MCItemIDListBase):
    pass


class MCEntityIDListBase:
    def __init__(self):
        ...


class MCEntityList(MCEntityIDListBase):
    pass
