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

from lib.utils import get_mc_itemlist
from lib.mc_server_cmds import give_player_item, get_server_objs
from lib.request_models import (
    RequestClient,
    ClientCacheSettings,
    ClientResponse,
    ClientCacheBackendSQLite,
)

_player: str = "r3djak"
_item: str = "chest"
_quant: int = 1


def debug_print_server_dirs(server_dirs: List[MCServer] = None):
    """
    Loop through server_dirs input, debug print chosen class values.
    """

    ## Loop list of server_dirs
    for server_dir in server_dirs:
        print(
            f"[DEBUG] Server directory '{server_dir.name}'\n\tClass object: [{server_dir}]\n\tBase path: {server_dir.base_dir}\n\tWhitelist file: {server_dir.whitelist_file}\n\tDocker Compose file: {server_dir.compose_file}Whitelist: {server_dir.whitelist}\n\tContents: {server_dir.whitelist.data}"
        )


def main():
    # server_dirs = get_server_objs()
    # # debug_print_server_dirs(server_dirs=server_dirs)

    # test_docker_cmd = test_give_cmd(server_obj=server_dirs[1], container="mc-server")

    # test_exec_cmd = test_docker_cmd.exec_cmd()
    # print(f"Test command results: {test_exec_cmd}")

    # mc_itemlist = get_mc_itemlist()
    # print(f"Test request res: {test_res._json}")
    # print(f"Test decoded content: {mc_itemlist._json}")

    cache_settings = ClientCacheSettings(
        cache_name="mc_itemlist", backend_type="sqlite"
    )
    cache_backend = ClientCacheBackendSQLite(db_path="./cache", use_cache_dir="./cache")
    mc_itemlist = get_mc_itemlist(
        use_cache=True,
        cache_settings=cache_settings,
        cache_backend=cache_backend.sqlite_cache,
    )

    print(f"Itemlist type: {type(mc_itemlist)}")
    print(f"Itemlist size: {mc_itemlist.size}")
    print(f"Status: {mc_itemlist.ok}, Status code: {mc_itemlist.status_code}")
    print(f"Used cache? {mc_itemlist.from_cache}")
    print(f"Revalidated? {mc_itemlist.revalidated}")
    # print(f"Data: {mc_itemlist._json}")
    # print(f"Request exists: {}")


if __name__ == "__main__":
    main()
