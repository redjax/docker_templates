from __future__ import annotations

import logging
from pathlib import Path
import typing as t

log = logging.getLogger(__name__)

from metadata.utils import is_ignored

__all__ = [
    "build_category_tree",
    "find_category_beacons",
    "find_template_beacons",
    "find_templates_in_dir"
]


def find_templates_in_dir(
    directory: Path,
    ignore_patterns: list[str],
    root: Path,
    template_file_indicators: list[str],
) -> list[dict]:
    templates = []
    for item in directory.rglob("*"):
        if item.is_file() and any(item.match(indicator) for indicator in template_file_indicators):
            if not is_ignored(item, ignore_patterns, root):
                template = {"name": item.parent.name, "path": str(item), "parent": item.parent}
                log.debug(f"Found template: {template}")
                templates.append(template)

    return templates


def build_category_tree(
    root: Path,
    current_path: Path,
    ignore_patterns: list[str],
    template_file_indicators: list[str],
) -> dict:
    category = {
        "name": current_path.name,
        "path": str(current_path),
        "templates": [],
        "sub_categories": []
    }

    for item in current_path.iterdir():
        if item.is_dir():
            if (item / ".category").exists():
                sub_category = build_category_tree(root, item, ignore_patterns, template_file_indicators)
                category["sub_categories"].append(sub_category)
            else:
                # Search for templates in this subdirectory
                templates = find_templates_in_dir(item, ignore_patterns, root, [".docker-compose.template"])
                category["templates"].extend(templates)
        elif item.is_file() and item.name == ".category":
            # We've already handled this by creating the category
            pass
        elif item.is_file() and any(item.match(indicator) for indicator in [".docker-compose.template"]):
            if not is_ignored(item, ignore_patterns, root):
                template = {"name": item.name, "path": str(item), "parent": item.parent}
                log.debug(f"Found template: {template}")
                category["templates"].append(template)

    return category

def find_category_beacons(
    templates_root_dir: t.Union[str, Path],
    ignore_patterns: list[str],
    template_file_indicators: list[str],
) -> list[dict]:
    if isinstance(templates_root_dir, str):
        templates_root_dir = Path(templates_root_dir)

    log.info(f"Finding categories in '{templates_root_dir}'")

    categories = []

    for item in templates_root_dir.iterdir():
        if item.is_dir() and (item / ".category").exists():
            category = build_category_tree(templates_root_dir, item, ignore_patterns, template_file_indicators)
            categories.append(category)

    log.debug(f"Discovered [{len(categories)}] top-level categories")
    return categories


def find_template_beacons(
    templates_root_dir: t.Union[str, Path],
    ignore_patterns: list[str],
    template_file_indicators: list[str],
) -> None:
    if isinstance(templates_root_dir, str):
        templates_root_dir = Path(templates_root_dir)

    log.info(f"Finding templates in '{templates_root_dir}'")

    templates: list[dict[str, t.Union[str, Path]]] = []
    seen_templates = set()
    
    log.debug(f"Template file indicators: {template_file_indicators}")

    for file in templates_root_dir.rglob("*"):
        try:
            if file.is_file() and any(
                file.match(indicator) for indicator in template_file_indicators
            ):
                log.debug(f"Path '{file}' is a file")
                if ignore_patterns:
                    log.debug(f"Checking if file '{file}' is ignored")
                    if is_ignored(file, ignore_patterns, templates_root_dir):
                        log.debug(f"Ignoring: {file}")
                        continue

                template_dir = file.parent  # Identify the template's directory
                log.debug(f"Template dir: {template_dir}")

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
