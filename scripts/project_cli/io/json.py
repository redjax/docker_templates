from __future__ import annotations

import json
import logging
from pathlib import Path
import typing as t

log = logging.getLogger(__name__)

__all__ = ["save_templates_to_json", "save_categories_to_json"]


def save_json(data: t.Union[str, dict], output_file: str) -> bool:
    try:
        Path(output_file).parent.mkdir(parents=True, exist_ok=True)
    except Exception as exc:
        log.error(f"({type(exc)}) Error creating path '{Path(output_file).parent}. Details: {exc}")
        return False
    
    log.debug(f"Saving JSON data to '{output_file}'")
    try:
        with open(output_file, "w", encoding="utf-8") as f:
            json_data = json.dumps(data, indent=4, default=str, sort_keys=True)
            # log.debug(f"JSON data:\n{json_data}")
            f.write(json_data)
    except Exception as exc:
        log.error(f"({type(exc)}) Error saving data to file '{output_file}'. Details: {exc}")
        return False
    
    return True
        

def save_templates_to_json(
    templates: list[dict[str, t.Union[str, Path]]], json_file: str
):
    if not templates:
        log.warning("No data to save as JSON")
        return

    log.info(f"Saving templates to JSON file: {json_file}")
    
    try:
        save_json(data=templates, output_file=json_file)
    except Exception as exc:
        log.error(f"({type(exc)}) Error saving templates to file. Details: {exc}")
        raise


def save_categories_to_json(categories: list[dict[str, t.Union[str, Path]]], json_file: str):
    if not categories:
        log.warning("No data to save as JSON")
        return

    log.info(f"Saving categories to JSON file: {json_file}")

    try:
        save_json(data=categories, output_file=json_file)
    except Exception as exc:
        log.error(f"({type(exc)}) Error saving categories to file. Details: {exc}")
        raise
