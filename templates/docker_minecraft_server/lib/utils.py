from pathlib import Path
from typing import Dict, List

import json


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
