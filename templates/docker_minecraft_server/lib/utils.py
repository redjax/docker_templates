from pathlib import Path
from typing import Dict, List

import json

# from lib.request_models import RequestClient, ResponseObj
from lib.request_models import (
    RequestClient,
    ClientCacheBackendSQLite,
    ClientCacheSettings,
    ClientResponse,
)

itemlist_url = "https://minecraft-ids.grahamedgecombe.com/items.json"


def whitelist_data(whitelist_file) -> Dict:
    """
    Return dict of whitelist file's JSON data.
    """

    ## Check if whitelist file exists
    if Path(whitelist_file).is_file():
        # print(f"Whitelist file for server [{self.name}] found at: {whitelist_path}")

        ## Open whitelist file
        read_whitelist = open(whitelist_file)
        ## Read contents into JSON
        whitelist_data = json.load(read_whitelist)

        ## Close file
        read_whitelist.close()

        ## Return dict of whitelist data
        return whitelist_data

    else:
        return None


def get_mc_itemlist(
    url: str = itemlist_url,
    use_cache: bool = False,
    cache_settings=None,
    cache_backend=None,
) -> ClientResponse:
    _client = RequestClient(
        url=url,
        use_cache=use_cache,
        cache_settings=cache_settings,
        cache_backend=cache_backend,
    )

    res = _client.get()
    print(f"Res type: {res}")

    return res
