"""Script to discover templates in the repo & publish the count to the README.md file for the repository.

Description:
    Discovers templates in the 'templates/' directory by detecting the presence of a `compose.yml`, `docker-compose.yml`, or `.env.example` file.
    Templates that have 1 or more matching file indicators are only counted once.
    
    Discovered repos are saved in a CSV and JSON file in the `./metadata/` directory, and a line in the README.md file is updated with the count.
    
Usage:
    python scripts/count_templates.py --help # Show CLI help.
    
    python scripts/count_templates.py --templates-root-dir "./templates" # Set the directory where templates are stored.
    
    python scripts/count_templates.py --update-all # Update all files (CSV, JSON, and README).
    
    python scripts/count_templates.py --save-csv # Update the CSV file only.
    
    python scripts/count_templates.py --save-json # Update the JSON file only.
    
    python scripts/count_templates.py --update-readme # Update the README file only.
    
Params:
    --templates-root-dir: Directory where templates are stored.
    --output-dir: Directory to save output files.
    --ignore-dirs: List of directories to ignore.
    --template-indicators: List of file indicators to use for template detection.
    --save-json: Save the templates to a JSON file.
    --json-file: JSON file to save templates to.
    --save-csv: Save the templates to a CSV file.
    --csv-file: CSV file to save templates to.
    --save-count: Save the templates count to a file.
    --count-file: File to save templates count to.
    --update-readme: Update the README file with the templates count.
    --update-all: Update all files (CSV, JSON, and README).
    --readme-file: README file to update.
"""

import argparse
import logging
from pathlib import Path
import typing as t
import json
import csv
import re

log = logging.getLogger(__name__)

## If this script is imported elsewhere, only export the following functions/vars
__all__ = [
    "TEMPLATES_ROOT",
    "OUTPUT_DIR",
    "IGNORE_DIRS",
    "TEMPLATE_INDICATORS",
    "discover_templates",
    "get_templates_df",
    "count",
]

## Path where docker templates are stored in the repo
TEMPLATES_ROOT: str = "./templates"
## Path to metadata directory where the CSV and JSON files will be saved
OUTPUT_DIR: str = "./metadata"
## Directory/file patterns to ignore during discovery
IGNORE_PATTERNS: list[str] = ["_cookiecutter", "docker_gickup/backup/"]
## File indicators to use for template detection
TEMPLATE_INDICATORS: list[str] = ["compose.yml", "docker-compose.yml", ".env.example"]

## When True, save to JSON
SAVE_JSON: bool = False
## When True, save to CSV
SAVE_CSV: bool = False
## When True, save to simple file with no extension
SAVE_COUNT: bool = False
## When True, update the repo's README.md
UPDATE_README: bool = False


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
    parser.add_argument(
        "--output-dir",
        type=str,
        default=OUTPUT_DIR,
        help="Directory to save output files",
    )
    ## Ignore
    parser.add_argument(
        "--ignore-pattern",
        type=str,
        nargs="*",
        default=IGNORE_PATTERNS,
        help="List of directories to ignore",
    )
    ## File/directory pattern indicating a path is a Docker template
    parser.add_argument(
        "--template-indicator",
        type=str,
        nargs="*",
        default=TEMPLATE_INDICATORS,
        help="List of template indicators",
    )
    ## When present, save to JSON
    parser.add_argument(
        "--save-json",
        action="store_true",
        default=SAVE_JSON,
        help="Save the templates to a JSON file",
    )
    ## JSON file to save templates to
    parser.add_argument(
        "--json-file",
        type=str,
        default="./metadata/templates.json",
        help="JSON file to save templates to",
    )
    ## When present, save to CSV
    parser.add_argument(
        "--save-csv",
        action="store_true",
        default=SAVE_CSV,
        help="Save the templates to a CSV file",
    )
    ## CSV file to save templates to
    parser.add_argument(
        "--csv-file",
        type=str,
        default="./metadata/templates.csv",
        help="CSV file to save templates to",
    )
    ## When present, save the count of templates to a file
    parser.add_argument(
        "--save-count",
        action="store_true",
        default=SAVE_COUNT,
        help="Save the count of templates",
    )
    ## Plaintext file to save count to
    parser.add_argument(
        "--count-file",
        type=str,
        default="./metadata/templates_count",
        help="File to save the count of templates to",
    )
    ## When present, updates the README.md file
    parser.add_argument(
        "--update-readme",
        action="store_true",
        default=UPDATE_README,
        help="Update the README file with the count of templates",
    )
    ## README.md file to update
    parser.add_argument(
        "--readme-file",
        type=str,
        default="./README.md",
        help="Path to the README file",
    )
    ## When present, updates all count files & the README.md file
    parser.add_argument(
        "--update-all",
        action="store_true",
        default=False,
        help="Update all files",
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


def is_ignored(
    file: Path, ignore_patterns: list[str], templates_root_dir: Path
) -> bool:
    """Check if a file is inside an ignored directory."""
    relative_path = file.relative_to(templates_root_dir)  # Get relative path

    for ignored in ignore_patterns:
        ignored_parts = Path(ignored).parts  # Split the ignored path into parts
        # Check if any part of the relative path contains the ignored directory parts
        if any(part.startswith(ignored_parts[0]) for part in relative_path.parts):
            return True  # If any part matches, ignore it

    return False


def discover_templates(
    templates_root_dir: Path,
    ignore_patterns: list[str],
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
                if is_ignored(file, ignore_patterns, templates_root_dir):
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


def update_readme_count(readme_file: str, new_count: int) -> None:
    """Update the template count in the README.md file."""

    ## Read the content of the README.md
    with open(readme_file, "r", encoding="utf-8") as file:
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
        with open(readme_file, "w", encoding="utf-8") as file:
            file.write(updated_content)
        log.info(f"Template count updated to {new_count} in README.md.")
    else:
        log.info("No update required for the README.md.")


def count(
    templates_root_dir: t.Union[str, Path],
    ignore_patterns: list[str] | None = None,
    template_file_indicators: list[str] | None = None,
    save_json: bool = False,
    save_csv: bool = False,
    save_count: bool = False,
    update_readme: bool = False,
    update_all_files: bool = False,
    json_file: str = "./templates.json",
    csv_file: str = "./templates.csv",
    count_file: str = "./templates_count",
    readme_file: str = "./README.md",
) -> int | None:
    """Script entrypoint, start count of Docker templates & optionally update files.

    Params:
        templates_root_dir: Directory where templates are stored.
        ignore_patterns: List of directories to ignore.
        template_file_indicators: List of file indicators to use for template detection.
        save_json: Save the templates to a JSON file.
        save_csv: Save the templates to a CSV file.
        save_count: Save the templates count to a file.
        update_readme: Update the README file with the templates count.
        update_all_files: Update all files (CSV, JSON, and README).
        json_file: JSON file to save templates to.
        csv_file: CSV file to save templates to.
        count_file: File to save templates count to.
        readme_file: README file to update.

    Returns:
        None

    Raises:
        ValueError: Missing templates root dir.
        FileNotFoundError: Could not find templates root directory.
    """
    ## Set defaults to avoid mutable default arguments issue
    if ignore_patterns is None:
        ignore_patterns = []
    if template_file_indicators is None:
        template_file_indicators = []

    ## Check for presence of templates directory
    if not templates_root_dir:
        raise ValueError("Missing templates root dir.")
    if not isinstance(templates_root_dir, Path):
        templates_root_dir = Path(templates_root_dir).expanduser()

    if not templates_root_dir.exists():
        raise FileNotFoundError(
            f"Could not find templates root directory at path: '{templates_root_dir}'"
        )

    ## Discover templates in templates root path
    try:
        templates = discover_templates(
            templates_root_dir=templates_root_dir,
            ignore_patterns=ignore_patterns,
            template_file_indicators=template_file_indicators,
        )
    except Exception as exc:
        msg = f"({type(exc)}) Error counting templates. Details: {exc}"
        log.error(msg)

        raise

    log.debug(f"Found {len(templates)} templates in '{templates_root_dir}'")

    ## No templates found
    if not templates or len(templates) == 0:
        log.warning(f"No templates found at path '{templates_root_dir}'.")
        return

    ## --update-all detected
    if update_all_files:
        log.info("Updating all metadata files")

        ## Update JSON file
        save_templates_to_json(templates=templates, json_file=json_file)
        ## Update CSV file
        save_templates_to_csv(templates=templates, csv_file=csv_file)
        ## Update plaintext count file
        save_count_to_file(templates=templates, count_file=count_file)
        ## Update repo README
        update_readme_count(readme_file=readme_file, new_count=len(templates))

    ## --save-json detected
    if save_json:
        ## Update JSON file
        save_templates_to_json(templates=templates, json_file=json_file)

    ## --save-csv detected
    if save_csv:
        ## Save CSV file
        save_templates_to_csv(templates=templates, csv_file=csv_file)

    ## --save-count detected
    if save_count:
        ## Update plaintext count file
        save_count_to_file(templates=templates, count_file=count_file)

    ## --update-readme detected
    if update_readme:
        ## Update repo README
        update_readme_count(readme_file=readme_file, new_count=len(templates))

    ## Return count of templates
    return len(templates) if templates else 0


if __name__ == "__main__":
    ## Parse user's CLI params
    args = parse_arguments()

    ## Setup logging
    logging.basicConfig(
        level=args.log_level.upper() or "INFO",
        format="%(asctime)s | %(levelname)s |> %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    ## Call count function
    try:
        templates_count: int | None = count(
            templates_root_dir=args.templates_root_dir or TEMPLATES_ROOT,
            ignore_patterns=args.ignore_pattern or IGNORE_PATTERNS,
            template_file_indicators=args.template_indicator or TEMPLATE_INDICATORS,
            save_json=args.save_json or SAVE_JSON,
            save_csv=args.save_csv or SAVE_CSV,
            save_count=args.save_count or SAVE_COUNT,
            update_readme=args.update_readme or UPDATE_README,
            update_all_files=args.update_all or False,
            json_file=args.json_file or f"{OUTPUT_DIR}/templates.json",
            csv_file=args.csv_file or f"{OUTPUT_DIR}/templates.csv",
            count_file=args.count_file or f"{OUTPUT_DIR}/templates_count",
            readme_file=args.readme_file or "./README.md",
        )

        ## Check and print results
        if not templates_count or templates_count == 0:
            print(f"No templates found in path '{args.templates_root_dir}'")
            exit(0)
        else:
            print(
                f"\nFound {templates_count} template(s) in '{args.templates_root_dir}'\n"
            )
            exit(0)
    except Exception as exc:
        msg = f"({type(exc)}) Error counting templates. Details: {exc}"
        log.error(msg)

        raise
