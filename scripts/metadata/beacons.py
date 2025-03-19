import logging
from pathlib import Path
import typing as t
import sys
import argparse
from jinja2 import Environment, FileSystemLoader

log = logging.getLogger(__name__)

## Add parent directory to PYTHONPATH dynamically
sys.path.append(str(Path(__file__).resolve().parent.parent))

__all__ = ["search_beacons", "find_category_beacons", "find_cookiecutter_template_beacons", "find_compose_template_beacons"]

from metadata.constants import TEMPLATES_ROOT, JINJA_TEMPLATE_DIR, OUTPUT_DIR, IGNORE_CATEGORY_NAMES_FILE, TEMPLATE_INDICATORS, TEMPLATE_BEACONS, CATEGORIES_METADATA_FILE

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

    ## Parse CLI args
    args = parser.parse_args()

    return args



def find_category_beacons(templates_dir: str, beacons: list[str]) -> list[dict]:
    log.debug(f"Searching path '{templates_dir}' for beacons: {beacons}")
    result = []
    try:
        for path in Path(templates_dir).rglob('*'):
            if path.is_file() and path.name in beacons:
                result.append({
                    'name': path.name,
                    'parent': str(path.parent.relative_to(templates_dir))
                })
        return result
    except Exception as exc:
        log.error(f"Error searching path '{templates_dir}' for beacons: {beacons}. Details: {exc}")
        raise


def find_cookiecutter_template_beacons(templates_dir: str, beacons: list[str]):
    log.debug(f"Searching path '{templates_dir}' for beacons: {beacons}")
    result = []
    try:
        for path in Path(templates_dir).rglob('*'):
            if path.is_file() and path.name in beacons:
                result.append({
                    'name': path.name,
                    'parent': str(path.parent.relative_to(templates_dir))
                })
        return result
    except Exception as exc:
        log.error(f"Error searching path '{templates_dir}' for beacons: {beacons}. Details: {exc}")
        raise


def find_compose_template_beacons(templates_dir: str, beacons: list[str]):
    log.debug(f"Searching path '{templates_dir}' for beacons: {beacons}")
    result = []
    try:
        for path in Path(templates_dir).rglob('*'):
            if path.is_file() and path.name in beacons:
                result.append({
                    'name': path.name,
                    'parent': str(path.parent.relative_to(templates_dir))
                })
        return result
    except Exception as exc:
        log.error(f"Error searching path '{templates_dir}' for beacons: {beacons}. Details: {exc}")
        raise


def search_beacons(templates_dir: str, beacons: dict = TEMPLATE_BEACONS):
    category_beacons = find_category_beacons(templates_dir=templates_dir, beacons=beacons["category"])
    log.debug(f"Category beacons ({len(category_beacons)}): {category_beacons}")
    
    cookiecutter_beacons = find_cookiecutter_template_beacons(templates_dir, beacons=beacons["cookiecutter_template"])
    log.debug(f"Cookiecutter beacons ({len(cookiecutter_beacons)}): {cookiecutter_beacons}")
    
    compose_beacons = find_compose_template_beacons(templates_dir, beacons=beacons["docker_template"])
    log.debug(f"Compose beacons ({len(compose_beacons)}): {compose_beacons}")
    
    beacons: dict = {"category_beacons": category_beacons, "cookiecutter_beacons": cookiecutter_beacons, "compose_beacons": compose_beacons}
    
    return beacons

    
if __name__ == "__main__":
    ## Parse user's CLI params
    args = parse_arguments()

    ## Setup logging
    logging.basicConfig(
        level=args.log_level.upper() or "INFO",
        format="%(asctime)s | %(levelname)s |> %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    search_beacons(templates_dir=TEMPLATES_ROOT)
