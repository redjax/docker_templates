# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "pandas",
#     "pyarrow",
# ]
# ///

import logging
from pathlib import Path
import typing as t
import json

log = logging.getLogger(__name__)

import pandas as pd

TEMPLATES_ROOT: str = "./templates"
OUTPUT_DIR: str = "./scripts/metadata"
IGNORE_DIRS: list[str] = ["_cookiecutter", "docker_gickup/backup/"]
TEMPLATE_INDICATORS: list[str] = ["compose.yml", "docker-compose.yml", ".env.example"]

SAVE_JSON: bool = True
SAVE_CSV: bool = True


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

    for indicator in template_file_indicators:
        for file in templates_root_dir.rglob(indicator):
            if is_ignored(file, ignore_dirs, templates_root_dir):
                log.debug(f"Ignoring file in ignored directory: {file}")
                continue

            template_key = (file.parent, file.name)  # Unique key for seen_templates

            if template_key not in seen_templates:
                template_obj = {
                    "template": file.name,
                    "parent": file.parent.name,
                    "path": file,
                    "path_parts": file.parts,
                }
                log.debug(f"Found template: {template_obj}")
                templates.append(template_obj)
                seen_templates.add(template_key)

    log.debug(f"Discovered [{len(templates)}] template(s)")
    return templates


def get_templates_df(
    templates: list[dict[str, t.Union[str, Path]]], cols: list[str] | None = None
) -> pd.DataFrame:
    try:
        return pd.DataFrame(templates, columns=cols)
    except Exception as exc:
        msg = f"({type(exc)}) Error creating templates DataFrame. Details: {exc}"
        log.error(msg)

        return pd.DataFrame()


def save_templates_to_json(
    templates: list[dict[str, t.Union[str, Path]]], json_file: str
):
    if not Path(json_file).parent.exists():
        try:
            Path(json_file).parent.mkdir(parents=True, exist_ok=True)
        except Exception as exc:
            msg = f"({type(exc)}) Error creating parent directory. Details: {exc}"
            log.error(msg)

            raise

    try:
        with open(json_file, "w") as f:
            json.dump(templates, f, sort_keys=True, default=str, indent=4)
            log.info(f"Templates saved to '{json_file}'")

        return True
    except Exception as exc:
        msg = f"({type(exc)}) Error writing templates to file. Details: {exc}"
        log.error(msg)

        return False


def save_templates_to_csv(
    templates: list[dict[str, t.Union[str, Path]]],
    csv_file: str,
    cols: list[str] | None,
    exclude_cols: list[str] | None = None,
):
    if not Path(csv_file).parent.exists():
        try:
            Path(csv_file).parent.mkdir(parents=True, exist_ok=True)
        except Exception as exc:
            msg = f"({type(exc)}) Error creating parent directory. Details: {exc}"
            log.error(msg)

            raise

    templates_df: pd.DataFrame = get_templates_df(templates=templates, cols=cols)

    ## Remove excluded columns if any
    if exclude_cols:
        templates_df = templates_df.drop(columns=exclude_cols, errors="ignore")

    try:
        templates_df.to_csv(csv_file, index=False)
        log.info(f"Templates saved to '{csv_file}'.")

        return True
    except Exception as exc:
        msg = f"({type(exc)}) Error writing templates to file. Details: {exc}"
        log.error(msg)

        return False


def main(
    templates_root_dir: t.Union[str, Path],
    ignore_dirs: list[str] | None = None,
    template_file_indicators: list[str] | None = None,
    save_json: bool = False,
    save_csv: bool = False,
    json_file: str = "./templates.json",
    csv_file: str = "./templates.csv",
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

    templates_df: pd.DataFrame = get_templates_df(templates)
    log.info(f"Templates ({templates_df.shape[0]}):\n{templates_df}")

    if save_json:
        save_templates_to_json(templates=templates, json_file=json_file)

    if save_csv:
        save_templates_to_csv(
            templates=templates,
            csv_file=csv_file,
            cols=["template", "parent", "path"],
            exclude_cols=["path_parts"],
        )


if __name__ == "__main__":
    logging.basicConfig(
        level="INFO",
        format="%(asctime)s | %(levelname)s |> %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    main(
        templates_root_dir=TEMPLATES_ROOT,
        ignore_dirs=IGNORE_DIRS,
        template_file_indicators=TEMPLATE_INDICATORS,
        save_json=SAVE_JSON,
        save_csv=SAVE_CSV,
        json_file=f"{OUTPUT_DIR}/templates.json",
        csv_file=f"{OUTPUT_DIR}/templates.csv",
    )
