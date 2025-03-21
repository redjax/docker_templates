import logging
import typing as t
import sys
import argparse

from metadata import count
from metadata.constants import (TEMPLATES_ROOT, METADATA_DIR, IGNORE_IN_COUNT, TEMPLATE_BEACONS, TEMPLATES_COUNT_FILE)

log = logging.getLogger(__name__)

def count_templates():
    ## Define args & pass into count subcommand
    args = argparse.Namespace(
        templates_root_dir=TEMPLATES_ROOT,
        output_dir=METADATA_DIR,
        ignore=IGNORE_IN_COUNT,
        beacon=TEMPLATE_BEACONS,
        save=True,
        count_file=TEMPLATES_COUNT_FILE,
        update_readme=True,
        readme_file="README.md",
    )
    
    log.info(f"Counting templates in path '{args.templates_root_dir}'")
    try:
        return count.count(args)
    except Exception as exc:
        log.error(f"Error saving templates count. Details: {exc}")
        exit(1)
    
def main():
    count.count()

if __name__ == "__main__":
    logging.basicConfig(level="INFO", format="%(asctime)s | %(levelname)s |> %(message)s", datefmt="%Y-%m-%d %H:%M:%S")

    main()
