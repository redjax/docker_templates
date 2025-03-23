from __future__ import annotations

import argparse
import json
import logging
from pathlib import Path

log = logging.getLogger(__name__)

from project_cli import io, search
from project_cli.constants import (
    IGNORE_IN_COUNT,
    METADATA_DIR,
    REPO_MAP_OUTPUT_DIR,
    REPO_MAP_TEMPLATE_DIR,
    TEMPLATE_BEACONS_DICT,
    TEMPLATES_METADATA_JSON_FILE,
    TEMPLATES_ROOT,
    TEMPLATES_METADATA_CSV_FILE,
    
)

__all__ = ["parse_arguments", "_metadata"]


def parse_arguments(subparsers):
    ## Initialize subcommand parser
    metadata_parser = subparsers.add_parser(
        "metadata",
        help="Operations for interacting with repo metadata."
    )
    
    ## Path to docker templates
    metadata_parser.add_argument(
        "--templates-root-dir",
        type=str,
        default=TEMPLATES_ROOT,
        help="Root directory for templates",
    )

    ## Path to metadata dir
    metadata_parser.add_argument(
        "--metadata-dir",
        default=METADATA_DIR,
        help="Path to directory where metadata files are stored"
    )
    
    ## Ignore patterns
    metadata_parser.add_argument(
        "--ignore",
        type=str,
        nargs="*",
        default=IGNORE_IN_COUNT,
        help="Ignore matching file/directory patterns in count",
    )
    
    ## Beacons
    metadata_parser.add_argument(
        "--beacon",
        type=list[str],
        nargs="*",
        default=TEMPLATE_BEACONS_DICT["category"],
        help="1 or more beacon file to search for, i.e. '.category', '.docker-compose.template'"
    )
    
    ## When present, save the templates to JSON metadata file
    metadata_parser.add_argument(
        "--save-json",
        action="store_true",
        default=False,
        help="Save the templates to metadata JSON file",
    )
    
    ## JSON file to save templates to
    metadata_parser.add_argument(
        "--json-file",
        type=str,
        default=TEMPLATES_METADATA_JSON_FILE,
        help="JSON file to save templates to",
    )
    
    ## When present, save to CSV
    metadata_parser.add_argument(
        "--save-csv",
        action="store_true",
        default=False,
        help="Save the templates to a CSV file",
    )
    
    ## CSV file to save templates to
    metadata_parser.add_argument(
        "--csv-file",
        type=str,
        default=TEMPLATES_METADATA_CSV_FILE,
        help="CSV file to save templates to",
    )
    
    # ## When present, update the repository map README file
    # metadata_parser.add_argument(
    #     "--update-repo-map",
    #     action="store_true",
    #     default=False,
    #     help="Update the repository map README file"
    # )
    
    # ## Directory where repo map README exists
    # metadata_parser.add_argument(
    #     "--map-template-dir",
    #     type=str,
    #     default=REPO_MAP_TEMPLATE_DIR,
    #     help="Directory where repository map template README exists"
    # )
        
    ## Limit output of discovered templates
    metadata_parser.add_argument(
        "--preview",
        type=int,
        default=10,
        help="Limit output of discovered metadata. Override with --show-all"
    )
    
    ## Show all templates, regardlesss of --preview
    metadata_parser.add_argument(
        "--show-all",
        action="store_true",
        default=False,
        help="Show all discovered templates. WARNING: this may produce a lot of output & push your history out of your shell's window",
    )
    
    metadata_parser.set_defaults(func=_metadata)
    
    
def _metadata(args: argparse.Namespace):
    templates_root_dir = args.templates_root_dir
    ignore_patterns = args.ignore
    save_json = args.save_json
    templates_metadata_json_file = args.json_file
    save_csv = args.save_csv
    templates_metadata_csv_file = args.csv_file
    beacons = args.beacon
    preview = args.preview
    show_all = args.show_all
    
    beacons = args.beacon
    
    if beacons is None:
        beacons = []
    if isinstance(beacons, str):
        log.debug(f"beacons is a str: {beacons}")
        beacons = [beacons]
    elif isinstance(beacons, list):
        beacons: list[str] = []
        for b in beacons:
            if isinstance(b, dict):
                beacons.append(b)
            elif isinstance(b, str):
                beacons.append(b["beacon"])
    elif isinstance(beacons, dict):
        beacons = [beacons["beacon"]]
                
    log.debug(f"Beacons: {beacons}")
    
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
        templates = search.find_template_beacons(
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
    
    if save_json:
        try:
            io.save_templates_to_json(templates=templates, json_file=templates_metadata_json_file)
            log.info(f"Saved templates metadata to {templates_metadata_json_file}")
        except Exception as exc:
            log.error(f"Error saving templates metadata to JSON file: '{templates_metadata_json_file}'. Details: {exc}")

    if save_csv:
        try:
            io.save_templates_to_csv(templates=templates, csv_file=templates_metadata_csv_file)
            log.info(f"Saved templates metadata to {templates_metadata_csv_file}")
        except Exception:
            log.error(f"Error saving templates metadata to CSV file: '{templates_metadata_csv_file}")
    
    try:
        _json = json.dumps(templates, indent=4, default=str, sort_keys=True)
    except Exception as exc:
        log.error(f"Unable to print templates metadata. Details: {exc}")

    if show_all:
        log.info(f"Templates:\n{_json}")

    elif preview:
        if preview == len(templates):
            log.info(f"Templates:\n{_json}")
        
        else:
            count = 0

            log.info(f"Previewing [{preview}/{len(templates)}] {'template' if len(templates) == 1 else 'templates'}")
            
            for template in templates:
                if count >= preview:
                    continue

                log.info(f"Template ({count + 1}/{preview}): {template}")
                count +=  1
