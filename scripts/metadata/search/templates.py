from __future__ import annotations

import logging
from pathlib import Path
import typing as t

log = logging.getLogger(__name__)

from metadata.utils import is_ignored

__all__ = ["find_beacons"]


def find_beacons(
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
