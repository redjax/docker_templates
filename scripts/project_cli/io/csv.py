from __future__ import annotations

import csv
import logging
from pathlib import Path
import typing as t

log = logging.getLogger(__name__)

__all__ = ["save_templates_to_csv"]


def save_templates_to_csv(
    templates: list[dict[str, t.Union[str, Path]]], csv_file: str
):
    if not templates:
        log.warning("No data to save as CSV")
        return

    log.info(f"Saving templates to CSV file: {csv_file}")

    Path(csv_file).parent.mkdir(parents=True, exist_ok=True)
    with open(csv_file, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=templates[0].keys())
        writer.writeheader()
        writer.writerows(templates)
    log.info(f"Saved CSV: {csv_file}")
