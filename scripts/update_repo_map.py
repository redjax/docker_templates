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
CATEGORIES_METADATA_FILE = "metadata/categories.json"


def parse_arguments():
    parser = argparse.ArgumentParser(description="Update the template map README via Jinja2.")

    parser.add_argument("--scan-path", type=str, default=TEMPLATES_ROOT, help="Path to scan for files")
    parser.add_argument("-d", "--template-dir", type=str, default=JINJA_TEMPLATE_DIR, help="Path to directory with Jinja templates")
    parser.add_argument("-t", "--template-file", type=str, default="README.md.j2", help="Path to the Jinja template to render")
    parser.add_argument("--ignore-categories-file", type=str, default=IGNORE_CATEGORY_NAMES_FILE, help="Path to file with category names to ignore")
    parser.add_argument("--log-level", type=str, default="INFO", help="Logging level (default: INFO)")
    parser.add_argument("--save-json", action="store_true", help="Save categories to a JSON file")
    parser.add_argument("--json-file", type=str, default=CATEGORIES_METADATA_FILE, help="JSON file to save categories")
    parser.add_argument("-o", "--output-dir", type=str, default=OUTPUT_DIR, help="Output directory for generated files")
    parser.add_argument("--dry-run", action="store_true", help="Perform a dry run without actual changes")

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

    json_data = json.dumps(categories, indent=4, default=str, sort_keys=True)
    if dry_run:
        log.info(f"[DRY RUN] JSON data would be saved to '{json_file}':\n{json_data}")
        return

    Path(json_file).parent.mkdir(parents=True, exist_ok=True)
    with open(json_file, "w", encoding="utf-8") as f:
        f.write(json_data)
    log.info(f"Saved JSON to: {json_file}")
    

def get_templates(search_dir: str, template_indicators: list[str], ignore_names: list[str]):
    templates: list = []
    
    for subdir in Path(search_dir).iterdir():
        if subdir.is_dir() and subdir.name not in ignore_names and has_template_indicators(subdir):
            templates.append({
                "name": subdir.name,
                "path": str(subdir),
            })
            
    return templates


def get_subcategories(category_path: str, ignore_names: list[str], template_indicators: list[str]) -> list[dict[str, t.Union[str, list]]]:
    subcategories = []
    for subdir in Path(category_path).iterdir():
        if subdir.is_dir() and subdir.name not in ignore_names and not has_template_indicators(subdir):
            subcategories.append({
                "name": subdir.name,
                "path": str(subdir),
                "count": sum(1 for _ in subdir.iterdir()),
                "templates": get_templates(search_dir=str(subdir), template_indicators=template_indicators, ignore_names=ignore_names),
                "sub_categories": get_subcategories(subdir, ignore_names, template_indicators)
            })
    return subcategories


def get_categories(templates_root: str, ignore_names: list[str], template_indicators: list[str]) -> list[dict[str, t.Union[str, list]]]:
    categories = []
    for category in Path(templates_root).iterdir():
        if category.is_dir() and category.name not in ignore_names:
            subcategories = get_subcategories(category, ignore_names, template_indicators=template_indicators)
            ## TODO: Get nested templates by searching at least 1 level down for template indicator files
            categories.append(
                {
                    "name": category.name,
                    "path": str(category),
                    "count": sum(1 for _ in category.iterdir()),
                    "templates": get_templates(search_dir=str(category), template_indicators=template_indicators, ignore_names=ignore_names),
                    "sub_categories": subcategories
                }
            )

    return categories


def render_jinja_template(template_dir: str, template_file: str, output_dir: str, context: dict, dry_run: bool):
    log.debug(f"Searching '{template_dir}' for template '{template_file}'")
    log.debug(f"Template context: {context}")

    log.info(f"Loading template: {template_dir}/{template_file}")
    env = Environment(loader=FileSystemLoader(template_dir))
    template = env.get_template(template_file)

    log.debug("Rendering context into template")
    rendered_content = template.render(context)
    output_path = Path(output_dir) / "README.md"

    if dry_run:
        log.info(f"[DRY RUN] Would have written the following content to '{output_path}':\n{rendered_content}")
        return

    log.info(f"Saving rendered template to file '{output_path}'")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(rendered_content)
    
    log.info(f"Rendered template to: {output_path}")


def update_repo_map(
    repo_map_output_dir: str,
    template_dir: str,
    template_file: str,
    template_indicators: list[str],
    ignored_categories_file: str,
    templates_root: str,
    output_json_file: str,
    save_json: bool,
    dry_run: bool,
):
    log.info(f"Loading ignored categories from file '{ignored_categories_file}'")
    ignore_category_names = load_ignored_categories(ignored_categories_file)
    log.debug(f"Ignore categories: {ignore_category_names}")

    log.info(f"Getting repository template categories from path '{templates_root}'")
    try:
        categories = get_categories(templates_root, ignore_category_names, template_indicators=template_indicators)
        log.debug(f"Categories: {categories}")
    except Exception as exc:
        msg = f"({type(exc)}) Error getting categories. Details: {exc}"
        log.error(msg)
        
        raise

    if save_json:
        log.info(f"Saving categories to JSON file: {output_json_file}")
        save_categories_to_json(categories, output_json_file, dry_run)

    context = {"categories": categories}
    log.info(f"Rendering Jinja2 template '{template_file}' from directory '{template_dir}' to '{repo_map_output_dir}'")
    render_jinja_template(template_dir, template_file, repo_map_output_dir, context, dry_run)


if __name__ == "__main__":
    args = parse_arguments()

    logging.basicConfig(
        level=args.log_level.upper(),
        format="%(asctime)s | %(levelname)s | %(module)s.%(funcName)s:%(lineno)d |> %(message)s" if args.log_level.upper() == 'DEBUG' else "%(asctime)s | %(levelname)s |> %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    try:
        update_repo_map(
            repo_map_output_dir=args.output_dir,
            template_dir=args.template_dir,
            template_file=args.template_file,
            template_indicators=TEMPLATE_INDICATORS,
            ignored_categories_file=args.ignore_categories_file,
            templates_root=args.scan_path,
            output_json_file=args.json_file,
            save_json=args.save_json,
            dry_run=args.dry_run,
        )
    except Exception as exc:
        log.critical(f"Error: {exc}")
        exit(1)
