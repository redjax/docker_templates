import logging
from pathlib import Path
import typing as t
import json
import argparse
from jinja2 import Environment, FileSystemLoader

log = logging.getLogger(__name__)

TEMPLATES_ROOT = "templates"
JINJA_TEMPLATE_DIR = "map/_template"
OUTPUT_DIR = "map"
IGNORE_CATEGORY_NAMES_FILE = "metadata/ignore_categories"
TEMPLATE_INDICATORS = ["*.env", "compose.yml", "docker-compose.yml", "*.env.example"]
TEMPLATE_BEACONS: dict = {"category": ".category", "docker_template": ".docker-compose.template", "cookiecutter_template": ".cookiecutter.template"}
CATEGORIES_METADATA_FILE = "metadata/categories.json"

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
    ## Path where JSON/CSV/filecount files will be saved
    # parser.add_argument(
    #     "--output-dir",
    #     type=str,
    #     default=OUTPUT_DIR,
    #     help="Directory to save output files",
    # )
    ## Ignore
    # parser.add_argument(
    #     "--ignore-pattern",
    #     type=str,
    #     nargs="*",
    #     default=IGNORE_PATTERNS,
    #     help="List of directories to ignore",
    # )
    ## File/directory pattern indicating a path is a Docker template
    # parser.add_argument(
    #     "--template-indicator",
    #     type=str,
    #     nargs="*",
    #     default=TEMPLATE_INDICATORS,
    #     help="List of template indicators",
    # )
    ## When present, save to JSON
    # parser.add_argument(
    #     "--save-json",
    #     action="store_true",
    #     default=SAVE_JSON,
    #     help="Save the templates to a JSON file",
    # )
    ## JSON file to save templates to
    # parser.add_argument(
    #     "--json-file",
    #     type=str,
    #     default="./metadata/templates.json",
    #     help="JSON file to save templates to",
    # )
    ## When present, save to CSV
    # parser.add_argument(
    #     "--save-csv",
    #     action="store_true",
    #     default=SAVE_CSV,
    #     help="Save the templates to a CSV file",
    # )
    ## CSV file to save templates to
    # parser.add_argument(
    #     "--csv-file",
    #     type=str,
    #     default="./metadata/templates.csv",
    #     help="CSV file to save templates to",
    # )
    ## When present, save the count of templates to a file
    # parser.add_argument(
    #     "--save-count",
    #     action="store_true",
    #     default=SAVE_COUNT,
    #     help="Save the count of templates",
    # )
    ## Plaintext file to save count to
    # parser.add_argument(
    #     "--count-file",
    #     type=str,
    #     default="./metadata/templates_count",
    #     help="File to save the count of templates to",
    # )
    ## When present, updates the README.md file
    # parser.add_argument(
    #     "--update-readme",
    #     action="store_true",
    #     default=UPDATE_README,
    #     help="Update the README file with the count of templates",
    # )
    ## README.md file to update
    # parser.add_argument(
    #     "--readme-file",
    #     type=str,
    #     default="./README.md",
    #     help="Path to the README file",
    # )
    ## When present, updates all count files & the README.md file
    # parser.add_argument(
    #     "--update-all",
    #     action="store_true",
    #     default=False,
    #     help="Update all files",
    # )
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


def main(templates_dir: str, beacons: dict = TEMPLATE_BEACONS):
    category_beacons = find_category_beacons(templates_dir=templates_dir, beacons=beacons["category"])
    log.debug(f"Category beacons ({len(category_beacons)}): {category_beacons}")
    
    cookiecutter_beacons = find_cookiecutter_template_beacons(templates_dir, beacons=beacons["cookiecutter_template"])
    log.debug(f"Cookiecutter beacons ({len(cookiecutter_beacons)}): {cookiecutter_beacons}")
    
    compose_beacons = find_compose_template_beacons(templates_dir, beacons=beacons["docker_template"])
    log.debug(f"Compose beacons ({len(compose_beacons)}): {compose_beacons}")

    
if __name__ == "__main__":
    ## Parse user's CLI params
    args = parse_arguments()

    ## Setup logging
    logging.basicConfig(
        level=args.log_level.upper() or "INFO",
        format="%(asctime)s | %(levelname)s |> %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    main(templates_dir=TEMPLATES_ROOT)
