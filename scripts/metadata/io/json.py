from __future__ import annotations

import json
import logging
from pathlib import Path
import typing as t

log = logging.getLogger(__name__)

__all__ = ["save_templates_to_json"]

def save_templates_to_json(
    templates: list[dict[str, t.Union[str, Path]]], json_file: str
):
    if not templates:
        log.warning("No data to save as JSON")
        return

    log.info(f"Saving templates to JSON file: {json_file}")

    Path(json_file).parent.mkdir(parents=True, exist_ok=True)
    with open(json_file, "w", encoding="utf-8") as f:
        json_data = json.dumps(templates, indent=4, default=str, sort_keys=True)
        log.debug(f"JSON data:\n{json_data}")
        f.write(json_data)
    log.info(f"Saved JSON: {json_file}")
