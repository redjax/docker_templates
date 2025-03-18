"""Script to update the template map README via cookiecutter.

Scans the template directory & dynamically updates the map based.
"""
import logging
from pathlib import Path
import typing as t
import json
import argparse
import cookiecutter
from cookiecutter.main import cookiecutter



log = logging.getLogger(__name__)

TEMPLATES_ROOT: str = "templates"
COOKIECUTTER_TEMPLATE: str = "map/_template"
OUTPUT_DIR: str = "map"
# IGNORE_CATEGORY_NAMES: list[str] = ["_cookiecutter", "docker_netdata", "docker_cloudflare-tunnel", "docker_wazuh", "docker_wordpress-nginx", "docker_drone"]
IGNORE_CATEGORY_NAMES_FILE: str = "metadata/ignore_categories"
TEMPLATE_INDICATORS = ["*.env", "compose.yml", "docker-compose.yml", "*.env.example"]
CATEGORIES_METADATA_FILE: str = "metadata/categories.json"


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
        default=CATEGORIES_METADATA_FILE,
        help="CSV file to save renamed files to",
    )
    ## Location where cookiecutter template will be rendered
    parser.add_argument(
        "-o", "--output-dir",
        type=str,
        default=OUTPUT_DIR,
        help="Directory where cookiecutter template will be rendered"
    )
    
    ## Dry run, where no actions will be taken
    parser.add_argument("--dry-run", action="store_true", help="Do a dry run, where no real action will be taken.")
    
    ## Parse CLI args
    args = parser.parse_args()

    return args


def load_ignored_categories(ignored_categories_file: str) -> list[str]:
    with open(ignored_categories_file, "r") as f:
        categories = f.read().splitlines()
        
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
    
    log.debug(f"Categories JSON output file: {json_file}")
    
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


def render_cookiecutter_template(cookiecutter_template: str, output_dir: str, dry_run: bool, no_input: bool = True, extra_context: dict = {}) -> bool:
    log.debug(f"Cookiecutter template path: '{cookiecutter_template}', output directory: '{output_dir}")
    if dry_run:
        log.info(f"[DRY RUN] Would have applied cookiecutter template at path '{cookiecutter_template}' to output directory '{output_dir}'")
        return True

    try:
        cookiecutter(cookiecutter_template, no_input=no_input, extra_context=extra_context, output_dir=output_dir)
        log.debug(f"Template rendered successfully to path '{output_dir}'")
        return True
    except Exception as exc:
        msg = f"({type(exc)})"
        log.error(msg)
        
        raise exc


def update_repo_map(repo_map_output_dir: str, cookiecutter_template: str, ignored_categories_file: str, templates_root: str, output_json_file: str, save_json: bool, dry_run: bool, cookiecutter_no_input: bool = True):
    log.info(f"Loading ignored categories from file '{ignored_categories_file}'")
    try:
        ignore_category_names = load_ignored_categories(ignored_categories_file=ignored_categories_file)
        log.debug(f"Ignored categories: {ignore_category_names}")
    except Exception as exc:
        msg = f"({type(exc)}) Error loading ignored categories. Details: {exc}"
        log.error(msg)
        
        raise

    log.info(f"Getting repository template categories from path '{templates_root}'") 
    try:
        categories: list[dict[str, t.Union[str, list[dict]]]] = get_categories(templates_root=templates_root, ignore_names=ignore_category_names)
        log.debug(f"Found [{len(categories)}] {'category' if len(categories) == 1 else 'categories'} in path: {TEMPLATES_ROOT}")
    except Exception as exc:
        msg = f"({type(exc)}) Error getting categories from root path '{templates_root}'. Details: {exc}"
        log.error(msg)
        
        raise
    
    if len(categories) > 0:
        log.debug(f"Found categories: {categories}")
    
    if save_json:
        log.info(f"Saving categories to JSON file: {output_json_file}")
        try:
            save_categories_to_json(categories=categories["categories"], json_file=output_json_file, dry_run=dry_run)
        except Exception as exc:
            msg = f"({type(exc)}) Error saving categories to JSON file '{output_json_file}'. Details: {exc}"
            log.error(msg)
    
    extra_context = {"categories": categories}
    log.info(f"Rendering cookiecutter template at path '{cookiecutter_template}' to output directory '{repo_map_output_dir}'")
    log.debug(f"Extra content ({type(extra_context)}): {extra_context}")
    try:
        render_cookiecutter_template(cookiecutter_template=cookiecutter_template, output_dir=repo_map_output_dir, dry_run=dry_run, no_input=cookiecutter_no_input, extra_context=extra_context)
    except Exception as exc:
        # msg = f"({type(exc)}) Error rendering cookiecutter template. Details: {exc}"
        # log.error(msg)
        raise exc
    

if __name__ == "__main__":
    args = parse_arguments()
    
    logging.basicConfig(
        level=args.log_level.upper() or "INFO",
        format="%(asctime)s | %(levelname)s |> %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    
    try:
        update_repo_map(
            repo_map_output_dir=args.output_dir,
            cookiecutter_template=COOKIECUTTER_TEMPLATE,
            ignored_categories_file=args.ignore_categories_file,
            templates_root=args.scan_path,
            output_json_file=args.json_file,
            save_json=args.save_json,
            dry_run=args.dry_run
        )
    except Exception as exc:
        msg = f"({type(exc)}) Error occurred while updating repository map template. Details: {exc}"
        log.error(msg)
        
        exit(1)
