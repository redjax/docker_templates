"""Script to update the template map README via cookiecutter.

Scans the template directory & dynamically updates the map based.
"""
import logging
from pathlib import Path
import typing as t
import json
import csv

import cookiecutter
from cookiecutter.main import cookiecutter

log = logging.getLogger(__name__)

TEMPLATES_ROOT: str = "templates"
COOKIECUTTER_TEMPLATE: str = "map/_template"
OUTPUT_DIR: str = "map"
IGNORE_CATEGORY_NAMES: list[str] = ["_cookiecutter"]
TEMPLATE_INDICATORS = ["*.env", "compose.yml", "docker-compose.yml", "*.env.example"]

def has_template_indicators(directory: str) -> bool:
    for pattern in TEMPLATE_INDICATORS:
        if any(Path(directory).glob(pattern)):
            return True

    return False


def save_categories_to_json(categories: list[dict[str, t.Union[str, list]]], json_file: str):
    if not categories:
        log.warning("No data to save as JSON")
        
        return
    
    log.info(f"Saving categories to JSON file: {json_file}")
    
    Path(json_file).parent.mkdir(parents=True, exist_ok=True)
    with open(json_file, "w", encoding="utf-8") as f:
        json_data = json.dumps(categories, indent=4, default=str, sort_keys=True)
        log.debug(f"JSON data:\n{json_data}")
        
        f.write(json_data)
        
    log.info(f"Saved JSON to: {json_file}")
    
    
def save_categories_to_csv(categories: list[dict[str, t.Union[str, list]]], csv_file: str):
    if not categories:
        log.warning("No data to save as CSV")
        return
    
    log.info(f"Saving categories to CSV file: {csv_file}")
    
    Path(csv_file).parent.mkdir(parents=True, exist_ok=True)
    with open(csv_file, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=categories[0].keys())
        writer.writeheader()
        writer.writerows(categories)
        
    log.info(f"Saved CSV: {csv_file}")


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
    logging.basicConfig(
        level="DEBUG",
        format="%(asctime)s | %(levelname)s |> %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    categories = get_categories(templates_root=TEMPLATES_ROOT, ignore_names=IGNORE_CATEGORY_NAMES)
    log.debug(f"Found [{len(categories)}] {'category' if len(categories) == 1 else 'categories'} in path: {TEMPLATES_ROOT}")
    
    if len(categories) > 0:
        log.debug(f"Found categories: {categories}")
    
    save_categories_to_json(categories=categories, json_file="metadata/categories.json")
    