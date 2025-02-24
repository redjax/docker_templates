import argparse
import logging
from pathlib import Path
import typing as t
import json
import csv
import re

log = logging.getLogger(__name__)

__all__ = [
    "TEMPLATES_ROOT",
    "OUTPUT_DIR",
    "IGNORE_DIRS",
    "TEMPLATE_INDICATORS",
    "discover_templates",
    "get_templates_df",
    "count",
]

TEMPLATES_ROOT: str = "./templates"
OUTPUT_DIR: str = "./metadata"
IGNORE_DIRS: list[str] = ["_cookiecutter", "docker_gickup/backup/"]
TEMPLATE_INDICATORS: list[str] = ["compose.yml", "docker-compose.yml", ".env.example"]

SAVE_JSON: bool = False
SAVE_CSV: bool = False
SAVE_COUNT: bool = False
UPDATE_README: bool = False


def parse_arguments():
    parser = argparse.ArgumentParser(description="Count repo templates")

    parser.add_argument(
        "--templates-root-dir",
        type=str,
        default=TEMPLATES_ROOT,
        help="Root directory for templates",
    )
    parser.add_argument(
        "--output-dir",
        type=str,
        default=OUTPUT_DIR,
        help="Directory to save output files",
    )
    parser.add_argument(
        "--ignore-dirs",
        type=str,
        nargs="*",
        default=IGNORE_DIRS,
        help="List of directories to ignore",
    )
    parser.add_argument(
        "--template-indicators",
        type=str,
        nargs="*",
        default=TEMPLATE_INDICATORS,
        help="List of template indicators",
    )
    parser.add_argument(
        "--save-json",
        action="store_true",
        default=SAVE_JSON,
        help="Save the templates to a JSON file",
    )
    parser.add_argument(
        "--json-file",
        type=str,
        default="./metadata/templates.json",
        help="JSON file to save templates to",
    )
    parser.add_argument(
        "--save-csv",
        action="store_true",
        default=SAVE_CSV,
        help="Save the templates to a CSV file",
    )
    parser.add_argument(
        "--csv-file",
        type=str,
        default="./metadata/templates.csv",
        help="CSV file to save templates to",
    )
    parser.add_argument(
        "--save-count",
        action="store_true",
        default=SAVE_COUNT,
        help="Save the count of templates",
    )
    parser.add_argument(
        "--count-file",
        type=str,
        default="./metadata/templates_count",
        help="File to save the count of templates to",
    )
    parser.add_argument(
        "--update-readme",
        action="store_true",
        default=UPDATE_README,
        help="Update the README file with the count of templates",
    )
    parser.add_argument(
        "--readme-path",
        type=str,
        default="./README.md",
        help="Path to the README file",
    )
    parser.add_argument(
        "--update-all",
        action="store_true",
        default=False,
        help="Update all files",
    )

    args = parser.parse_args()

    return args


def is_ignored(file: Path, ignore_dirs: list[str], templates_root_dir: Path) -> bool:
    """Check if a file is inside an ignored directory."""
    relative_path = file.relative_to(templates_root_dir)  # Get relative path

    for ignored in ignore_dirs:
        ignored_parts = Path(ignored).parts  # Split the ignored path into parts
        # Check if any part of the relative path contains the ignored directory parts
        if any(part.startswith(ignored_parts[0]) for part in relative_path.parts):
            return True  # If any part matches, ignore it

    return False


def discover_templates(
    templates_root_dir: Path,
    ignore_dirs: list[str],
    template_file_indicators: list[str],
) -> None:
    log.info(f"Counting templates in '{templates_root_dir}'")

    templates: list[dict[str, t.Union[str, Path]]] = []
    seen_templates = set()

    for file in templates_root_dir.rglob("*"):  # Scan all files
        try:
            if file.is_file() and any(
                file.match(indicator) for indicator in template_file_indicators
            ):
                if is_ignored(file, ignore_dirs, templates_root_dir):
                    log.debug(f"Ignoring file in ignored directory: {file}")
                    continue

                template_dir = file.parent  # Identify the template's directory

                if template_dir in seen_templates:
                    log.debug(f"Skipping already counted directory: {template_dir}")
                    continue  # Skip if the directory was already counted

                # Mark directory as counted
                seen_templates.add(template_dir)

                template_obj = {
                    "template": file.name,
                    "parent": file.parent.name,
                    "path": file.parent,  # Store directory instead of file path
                    "path_parts": file.parent.parts,
                }
                log.debug(f"Found template directory: {template_obj}")
                templates.append(template_obj)
        except PermissionError as e:
            log.error(e)
            continue
        except Exception as exc:
            msg = f"({type(exc)}) Error counting templates. Details: {exc}"
            log.error(msg)
            continue

    log.debug(f"Discovered [{len(templates)}] unique template directory(ies)")
    return templates


def save_templates_to_json(
    templates: list[dict[str, t.Union[str, Path]]], json_file: str
):
    Path(json_file).parent.mkdir(parents=True, exist_ok=True)
    with open(json_file, "w", encoding="utf-8") as f:
        json.dump(templates, f, indent=4, default=str, sort_keys=True)
    log.info(f"Saved JSON: {json_file}")


def save_templates_to_csv(
    templates: list[dict[str, t.Union[str, Path]]], csv_file: str
):
    if not templates:
        log.warning("No data to save as CSV")
        return
    Path(csv_file).parent.mkdir(parents=True, exist_ok=True)
    with open(csv_file, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=templates[0].keys())
        writer.writeheader()
        writer.writerows(templates)
    log.info(f"Saved CSV: {csv_file}")


def save_count_to_file(templates: list[dict[str, t.Union[str, Path]]], count_file: str):
    count: int = len(templates)
    try:
        with open(count_file, "w") as f:
            f.write(str(count))
            log.info(f"Templates count saved to '{count_file}'.")

        return True
    except Exception as exc:
        msg = f"({type(exc)}) Error writing templates count to file. Details: {exc}"
        log.error(msg)

        return False


def update_readme_count(readme_path: str, new_count: int) -> None:
    """Update the template count in the README.md file."""

    ## Read the content of the README.md
    with open(readme_path, "r", encoding="utf-8") as file:
        readme_content = file.read()

    log.debug(f"Original README content:\n{readme_content}")

    # Regex to find the "Templates: #" line where the number is at the end
    count_line_regex = r"Templates:\s*\d+"
    log.debug("Regex match:", re.findall(count_line_regex, readme_content))

    # Replace the old count with the new count
    updated_content = re.sub(
        count_line_regex, r"Templates: " + str(new_count), readme_content
    )

    # Print the updated content for debugging
    log.debug(f"Updated README content:\n{updated_content}")

    # If the content was updated, write the changes back to the file
    if updated_content != readme_content:
        with open(readme_path, "w", encoding="utf-8") as file:
            file.write(updated_content)
        log.info(f"Template count updated to {new_count} in README.md.")
    else:
        log.info("No update required for the README.md.")


def count(
    templates_root_dir: t.Union[str, Path],
    ignore_dirs: list[str] | None = None,
    template_file_indicators: list[str] | None = None,
    save_json: bool = False,
    save_csv: bool = False,
    save_count: bool = False,
    update_readme: bool = False,
    update_all_files: bool = False,
    json_file: str = "./templates.json",
    csv_file: str = "./templates.csv",
    count_file: str = "./templates_count",
    readme_path: str = "./README.md",
) -> None:
    # Set defaults to avoid mutable default arguments issue
    if ignore_dirs is None:
        ignore_dirs = []
    if template_file_indicators is None:
        template_file_indicators = []

    if not templates_root_dir:
        raise ValueError("Missing templates root dir.")
    if not isinstance(templates_root_dir, Path):
        templates_root_dir = Path(templates_root_dir).expanduser()

    if not templates_root_dir.exists():
        raise FileNotFoundError(
            f"Could not find templates root directory at path: '{templates_root_dir}'"
        )

    try:
        templates = discover_templates(
            templates_root_dir=templates_root_dir,
            ignore_dirs=ignore_dirs,
            template_file_indicators=template_file_indicators,
        )
    except Exception as exc:
        msg = f"({type(exc)}) Error counting templates. Details: {exc}"
        log.error(msg)

        raise

    log.debug(f"Found {len(templates)} templates in '{templates_root_dir}'")

    if not templates or len(templates) == 0:
        log.warning(f"No templates found at path '{templates_root_dir}'.")
        return

    if update_all_files:
        log.info("Updating all metadata files")
        save_templates_to_json(templates=templates, json_file=json_file)

        save_templates_to_csv(templates=templates, csv_file=csv_file)

        save_count_to_file(templates=templates, count_file=count_file)
        update_readme_count(readme_path=readme_path, new_count=len(templates))

    if save_json:
        save_templates_to_json(templates=templates, json_file=json_file)

    if save_csv:
        save_templates_to_csv(templates=templates, csv_file=csv_file)

    if save_count:
        save_count_to_file(templates=templates, count_file=count_file)

    if update_readme:
        update_readme_count(readme_path=readme_path, new_count=len(templates))

    return len(templates) if templates else 0


if __name__ == "__main__":
    logging.basicConfig(
        level="INFO",
        format="%(asctime)s | %(levelname)s |> %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    args = parse_arguments()

    count(
        templates_root_dir=args.templates_root_dir or TEMPLATES_ROOT,
        ignore_dirs=args.ignore_dirs or IGNORE_DIRS,
        template_file_indicators=args.template_indicators or TEMPLATE_INDICATORS,
        save_json=args.save_json or SAVE_JSON,
        save_csv=args.save_csv or SAVE_CSV,
        save_count=args.save_count or SAVE_COUNT,
        update_readme=args.update_readme or UPDATE_README,
        update_all_files=args.update_all or False,
        json_file=args.json_file or f"{OUTPUT_DIR}/templates.json",
        csv_file=args.csv_file or f"{OUTPUT_DIR}/templates.csv",
        count_file=args.count_file or f"{OUTPUT_DIR}/templates_count",
        readme_path=args.readme_path or "./README.md",
    )
