"""Script to update the template map README via cookiecutter.

Scans the template directory & dynamically updates the map based.
"""
import logging
from pathlib import Path
import typing as t
import json
import argparse


log = logging.getLogger(__name__)

TEMPLATES_ROOT: str = "templates"
COOKIECUTTER_TEMPLATE: str = "map/_template"
OUTPUT_DIR: str = "map"
# IGNORE_CATEGORY_NAMES: list[str] = ["_cookiecutter", "docker_netdata", "docker_cloudflare-tunnel", "docker_wazuh", "docker_wordpress-nginx", "docker_drone"]
IGNORE_CATEGORY_NAMES_FILE: str = "metadata/ignore_categories"
TEMPLATE_INDICATORS = ["*.env", "compose.yml", "docker-compose.yml", "*.env.example"]


def parse_arguments():
    parser = argparse.ArgumentParser(description="Find any docker-compose.yaml, compose.yaml file and rename it to 'compose.yml'.")
    
    parser.add_argument("--scan-path", type=str, default=TEMPLATES_ROOT, help="Path to scan for files")
    
    # parser.add_argument("--ignore-pattern", type=str, nargs="*", default=IGNORE_PATTERNS, help="File/path names to ignore")
    
    parser.add_argument("--template-indicator", type=str, nargs="*", default=TEMPLATE_INDICATORS, help="List of template indicators")
    
    parser.add_argument("--ignore-categories-file", type=str, default=IGNORE_CATEGORY_NAMES_FILE, help="Path to a file containing category names to ignore/skip")
    
    ## Set logging level
    parser.add_argument(
        "--log-level",
        type=str,
        default="INFO",
        help="The logging level to use. Default is 'INFO'. Options are: ['NOTSET', 'DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL']",
    )
    
    ## When present, save to CSV
    parser.add_argument(
        "--save-json",
        action="store_true",
        help="Save the renamed files to a JSON file",
    )
    ## CSV file to save renamed files to
    parser.add_argument(
        "--json-file",
        type=str,
        default="./metadata/categories.json",
        help="CSV file to save renamed files to",
    )
    
    ## Dry run, where no actions will be taken
    parser.add_argument("--dry-run", action="store_true", help="Do a dry run, where no real action will be taken.")
    
    ## Parse CLI args
    args = parser.parse_args()

    return args


def load_ignored_categories(ignored_categories_file: str) -> list[str]:
    with open(ignored_categories_file, "r") as f:
        categories = f.read()
        
    return categories


def has_template_indicators(directory: str) -> bool:
    for pattern in TEMPLATE_INDICATORS:
        if any(Path(directory).glob(pattern)):
            return True

    return False


def save_categories_to_json(categories: list[dict[str, t.Union[str, list]]], json_file: str, dry_run: bool):
    if not categories:
        log.warning("No data to save as JSON")
        
        return
    
    log.info(f"Saving categories to JSON file: {json_file}")
    
    json_data = json.dumps(categories, indent=4, default=str, sort_keys=True)
    if dry_run:
        log.info(f"[DRY RUN] Would have saved the following JSON to file '{json_file}':\n{json_data}")
        return
    
    Path(json_file).parent.mkdir(parents=True, exist_ok=True)
    with open(json_file, "w", encoding="utf-8") as f:
        log.debug(f"JSON data:\n{json_data}")
        
        f.write(json_data)
        
        log.info(f"Saved JSON to: {json_file}")


def get_subcategories(category_path: str, ignore_names: list[str]) -> list[dict[str, t.Union[str, list]]]:
    subcategories: list[dict[str, t.Union[str, list]]] = []

    for subdir in Path(category_path).iterdir():
        if Path(subdir).is_dir() and Path(subdir).name not in ignore_names:
            if not has_template_indicators(subdir):
                subcategories.append({
                    "name": Path(subdir).name,
                    "sub_categories": get_subcategories(subdir, ignore_names)
                })

    return subcategories

def get_categories(templates_root: str, ignore_names: list[str]) -> list[dict[str, t.Union[str, list]]]:
    categories: list[dict[str, t.Union[str, list]]] = []

    for category in Path(templates_root).iterdir():
        if category.is_dir() and category.name not in ignore_names:
            subcategories = get_subcategories(category, ignore_names)
            categories.append({"name": category.name, "sub_categories": subcategories})

    return categories

if __name__ == "__main__":
    args = parse_arguments()
    
    logging.basicConfig(
        level=args.log_level.upper() or "INFO",
        format="%(asctime)s | %(levelname)s |> %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    
    IGNORE_CATEGORY_NAMES = load_ignored_categories(ignored_categories_file=args.ignore_categories_file or IGNORE_CATEGORY_NAMES_FILE)
    log.debug(f"Ignored categories: {IGNORE_CATEGORY_NAMES}")

    categories = get_categories(templates_root=args.scan_path or TEMPLATES_ROOT, ignore_names=IGNORE_CATEGORY_NAMES)
    log.debug(f"Found [{len(categories)}] {'category' if len(categories) == 1 else 'categories'} in path: {TEMPLATES_ROOT}")
    
    if len(categories) > 0:
        log.debug(f"Found categories: {categories}")
    
    save_categories_to_json(categories=categories, json_file="metadata/categories.json", dry_run=args.dry_run)
    