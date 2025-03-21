from __future__ import annotations

import argparse
import logging
from pathlib import Path
import re
import typing as t

log = logging.getLogger(__name__)

from metadata import search
from metadata.constants import (
    IGNORE_IN_COUNT,
    METADATA_DIR,
    TEMPLATE_BEACONS,
    TEMPLATES_COUNT_FILE,
    TEMPLATES_ROOT,
)

__all__ = ["parse_arguments", "count"]


def parse_arguments(subparsers):
    ## Create parser
    count_parser = subparsers.add_parser("count", help="Count repo templates")

    ## Path to docker templates
    count_parser.add_argument(
        "--templates-root-dir",
        type=str,
        default=TEMPLATES_ROOT,
        help="Root directory for templates",
    )
    
    ## Path where JSON/CSV/filecount files will be saved
    count_parser.add_argument(
        "--output-dir",
        type=str,
        default=METADATA_DIR,
        help="Directory to save output files",
    )
    
    ## Ignore patterns
    count_parser.add_argument(
        "--ignore",
        type=str,
        nargs="*",
        default=IGNORE_IN_COUNT,
        help="Ignore matching file/directory patterns in count",
    )
    
    ## Beacons
    count_parser.add_argument(
        "--beacon",
        type=list[str],
        nargs="*",
        default=TEMPLATE_BEACONS,
        help="1 or more beacon file to search for, i.e. '.category', '.docker-compose.template'"
    )
    
    ## When present, save the count of templates to a file
    count_parser.add_argument(
        "--save",
        action="store_true",
        default=False,
        help="Save the count of templates",
    )
    
    ## Plaintext file to save count to
    count_parser.add_argument(
        "--count-file",
        type=str,
        default=TEMPLATES_COUNT_FILE,
        help="File to save the count of templates to",
    )
    
    ## When present, updates the README.md file
    count_parser.add_argument(
        "--update-readme",
        action="store_true",
        default=False,
        help="Update the README file with the count of templates",
    )
    
    ## README.md file to update
    count_parser.add_argument(
        "--readme-file",
        type=str,
        default="./README.md",
        help="Path to the README file",
    )
    
    count_parser.set_defaults(func=count)


def save_count_to_file(templates: list[dict[str, t.Union[str, Path]]], count_file: str):
    count: int = len(templates)
    
    if Path(count_file).exists():
        with open(count_file, "r") as f:
            existing_count = int(f.read())
            
            if count == existing_count:
                log.warning(f"Repository count has not changed. Counted [{count}] {'template' if count == 1 else 'templates'}")

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
    log.debug(f"Regex match: {re.findall(count_line_regex, readme_content)}")

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


def count(args: argparse.Namespace) -> int:
    templates_root_dir = args.templates_root_dir
    ignore_patterns = args.ignore
    save_count = args.save
    count_file = args.count_file
    update_readme = args.update_readme
    readme_file = args.readme_file
    beacons = args.beacon  
    
    ## Set defaults to avoid mutable default arguments issue
    if ignore_patterns is None:
        ignore_patterns = []
    elif isinstance(ignore_patterns, str):
        ignore_patterns = [ignore_patterns]
        
    if beacons is None:
        beacons = []
    if isinstance(beacons, str):
        beacons = [beacons]

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
        templates = search.discover_templates(
            templates_root_dir=templates_root_dir,
            ignore_patterns=ignore_patterns,
            template_file_indicators=beacons,
        )
    except Exception as exc:
        msg = f"({type(exc)}) Error counting templates. Details: {exc}"
        log.error(msg)

        raise
    
    ## No templates found
    if not templates or len(templates) == 0:
        log.warning(f"No templates found at path '{templates_root_dir}'.")
        return

    if save_count:
        try:
            save_count_to_file(templates=templates, count_file=count_file)
        except Exception as exc:
            log.error(f"Error saving templates count to file '{count_file}'. Details: {exc}")
    
    if update_readme:
        update_readme_count(readme_file=readme_file, new_count=len(templates))

    log.info(f"Found [{len(templates)}] {'template' if len(templates) == 1 else 'templates'}")

    ## Return count of templates
    return len(templates) if templates else 0
