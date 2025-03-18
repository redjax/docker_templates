import logging
from pathlib import Path
import typing as t
import json
import argparse
from jinja2 import Environment, FileSystemLoader

log = logging.getLogger(__name__)

TEMPLATES_ROOT = "templates"
TEMPLATE_DIR = "map/_template"
OUTPUT_DIR = "map"
IGNORE_CATEGORY_NAMES_FILE = "metadata/ignore_categories"
TEMPLATE_INDICATORS = ["*.env", "compose.yml", "docker-compose.yml", "*.env.example"]
CATEGORIES_METADATA_FILE = "metadata/categories.json"


def parse_arguments():
    parser = argparse.ArgumentParser(description="Update the template map README via Jinja2.")

    parser.add_argument("--scan-path", type=str, default=TEMPLATES_ROOT, help="Path to scan for files")
    parser.add_argument("--template-dir", type=str, default=TEMPLATE_DIR, help="Path to Jinja2 templates")
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


def get_subcategories(category_path: str, ignore_names: list[str]) -> list[dict[str, t.Union[str, list]]]:
    subcategories = []
    for subdir in Path(category_path).iterdir():
        if subdir.is_dir() and subdir.name not in ignore_names and has_template_indicators(subdir):
            subcategories.append({
                "name": subdir.name,
                "sub_categories": get_subcategories(subdir, ignore_names)
            })
    return subcategories


def get_categories(templates_root: str, ignore_names: list[str]) -> list[dict[str, t.Union[str, list]]]:
    categories = []
    for category in Path(templates_root).iterdir():
        if category.is_dir() and category.name not in ignore_names:
            subcategories = get_subcategories(category, ignore_names)
            categories.append({"name": category.name, "sub_categories": subcategories})
    return categories


def render_jinja_template(template_dir: str, output_dir: str, context: dict, dry_run: bool):
    env = Environment(loader=FileSystemLoader(template_dir))
    template = env.get_template("README.md")  # Example template name

    rendered_content = template.render(context)
    output_path = Path(output_dir) / "README.md"

    if dry_run:
        log.info(f"[DRY RUN] Would have written the following content to '{output_path}':\n{rendered_content}")
        return

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(rendered_content)
    log.info(f"Rendered template saved to: {output_path}")


def update_repo_map(
    repo_map_output_dir: str,
    template_dir: str,
    ignored_categories_file: str,
    templates_root: str,
    output_json_file: str,
    save_json: bool,
    dry_run: bool,
):
    log.info(f"Loading ignored categories from file '{ignored_categories_file}'")
    ignore_category_names = load_ignored_categories(ignored_categories_file)

    log.info(f"Getting repository template categories from path '{templates_root}'")
    categories = get_categories(templates_root, ignore_category_names)

    if save_json:
        log.info(f"Saving categories to JSON file: {output_json_file}")
        save_categories_to_json(categories, output_json_file, dry_run)

    context = {"categories": categories}
    log.info(f"Rendering Jinja2 template from directory '{template_dir}' to '{repo_map_output_dir}'")
    render_jinja_template(template_dir, repo_map_output_dir, context, dry_run)


if __name__ == "__main__":
    args = parse_arguments()

    logging.basicConfig(
        level=args.log_level.upper(),
        format="%(asctime)s | %(levelname)s |> %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    try:
        update_repo_map(
            repo_map_output_dir=args.output_dir,
            template_dir=args.template_dir,
            ignored_categories_file=args.ignore_categories_file,
            templates_root=args.scan_path,
            output_json_file=args.json_file,
            save_json=args.save_json,
            dry_run=args.dry_run,
        )
    except Exception as exc:
        log.error(f"Error: {exc}")
        exit(1)
