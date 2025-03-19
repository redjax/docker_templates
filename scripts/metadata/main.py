import logging
from pathlib import Path
import typing as t
import sys
import argparse
from jinja2 import Environment, FileSystemLoader

log = logging.getLogger(__name__)

## Add parent directory to PYTHONPATH dynamically
sys.path.append(str(Path(__file__).resolve().parent.parent))

from metadata.constants import TEMPLATES_ROOT, JINJA_TEMPLATE_DIR, OUTPUT_DIR, IGNORE_CATEGORY_NAMES_FILE, TEMPLATE_INDICATORS, TEMPLATE_BEACONS, CATEGORIES_METADATA_FILE
from metadata import beacons

def parse_arguments():
    """Parse CLI args passed to the script.

    Returns:
        argparse.Namespace: Parsed CLI args.
    """
    ## Create parser
    parser = argparse.ArgumentParser(description="Count repo templates")

    ## Path to docker templates
    parser.add_argument(
        "--templates-root-dir",
        type=str,
        default=TEMPLATES_ROOT,
        help="Root directory for templates",
    )
    ## Set logging level
    parser.add_argument(
        "--log-level",
        type=str,
        default="INFO",
        help="The logging level to use. Default is 'INFO'. Options are: ['NOTSET', 'DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL']",
    )
    ## File/directory pattern indicating a path is a Docker template
    parser.add_argument(
        "--beacon",
        type=str,
        nargs="*",
        default=TEMPLATE_BEACONS,
        help="List of template indicators",
    )

    ## Parse CLI args
    args = parser.parse_args()

    return args


def run(templates_dir: str = TEMPLATES_ROOT, template_beacons: list[str] = TEMPLATE_BEACONS):    
    log.info("Searching for template & category beacons")
    _beacons = beacons.search_beacons(templates_dir=templates_dir, beacons=template_beacons)


if __name__ == "__main__":
    ## Parse user's CLI params
    args = parse_arguments()

    ## Setup logging
    logging.basicConfig(
        level=args.log_level.upper() or "INFO",
        format="%(asctime)s | %(levelname)s |> %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    
    run(templates_dir=args.templates_root_dir, template_beacons=args.beacon)
