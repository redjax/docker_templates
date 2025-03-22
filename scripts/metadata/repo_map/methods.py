from __future__ import annotations

import argparse
import json
import logging
from pathlib import Path
import typing as t

from jinja2 import Environment, FileSystemLoader

log = logging.getLogger(__name__)

from metadata.constants import TEMPLATE_BEACONS_DICT, TEMPLATES_ROOT, REPO_MAP_TEMPLATE_DIR, REPO_MAP_OUTPUT_DIR, CATEGORIES_METADATA_JSON_FILE, IGNORE_TEMPLATE_CATEGORIES
from metadata import search,io

__all__ = ["parse_arguments", "_categories"]

def parse_arguments(subparsers):
    repo_map_parser = subparsers.add_parser("map", help="Interact with the repository map file in ./map")
    
    repo_map_parser.add_argument("--scan-path", type=str, default=TEMPLATES_ROOT, help="Path to scan for files")
    repo_map_parser.add_argument("--template-dir", type=str, default=REPO_MAP_TEMPLATE_DIR, help="Path to directory with Jinja templates")
    repo_map_parser.add_argument("-t", "--template-file", type=str, default="README.md.j2", help="Path to the Jinja template to render")
    repo_map_parser.add_argument("--ignore", type=str, default=IGNORE_TEMPLATE_CATEGORIES, help="1 or more file/dir name pattern to ignore")
    repo_map_parser.add_argument("--save-json", action="store_true", help="Save categories to a JSON file")
    repo_map_parser.add_argument("--json-file", type=str, default=CATEGORIES_METADATA_JSON_FILE, help="JSON file to save categories")
    repo_map_parser.add_argument("-o", "--output-dir", type=str, default=REPO_MAP_OUTPUT_DIR, help="Output directory for generated files")
    # repo_map_parser.add_argument("--dry-run", action="store_true", help="Perform a dry run without actual changes")
    ## Beacons
    repo_map_parser.add_argument(
        "--beacon",
        type=list[str],
        nargs="*",
        default=TEMPLATE_BEACONS_DICT["category"],
        help="1 or more beacon filename to search for, i.e. '.category', '.docker-compose.template'"
    )
    ## When present, update the repository map README file
    repo_map_parser.add_argument(
        "--update-repo-map",
        action="store_true",
        default=False,
        help="Update the repository map README file"
    )
    
    ## Directory where repo map README exists
    repo_map_parser.add_argument(
        "--map-template-dir",
        type=str,
        default=REPO_MAP_TEMPLATE_DIR,
        help="Directory where repository map template README exists"
    )
    
    repo_map_parser.set_defaults(func=_categories)
    
    
def render_jinja_template(template_dir: str, template_file: str, output_dir: str, context: dict, dry_run: bool):
    log.debug(f"Searching '{template_dir}' for template '{template_file}'")
    log.debug(f"Template context: {context}")

    log.info(f"Loading template: {template_dir}/{template_file}")
    env = Environment(loader=FileSystemLoader(template_dir))
    template = env.get_template(template_file)

    log.debug("Rendering context into template")
    rendered_content = template.render(context)
    output_path = Path(output_dir) / "README.md"

    if dry_run:
        log.info(f"[DRY RUN] Would have written the following content to '{output_path}':\n{rendered_content}")
        return

    log.info(f"Saving rendered template to file '{output_path}'")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(rendered_content)
    
    log.info(f"Rendered template to: {output_path}")

    

def _categories(args: argparse.Namespace):
    scan_path = args.scan_path
    ignore_patterns = args.ignore
    beacons = args.beacon
    update_repo_map = args.update_repo_map
    map_template_dir = args.map_template_dir
    save_json = args.save_json
    json_file = args.json_file
    # dry_run = args.dry_run
    
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
    
    ## Discover categories in templates root path
    try:
        categories = search.find_beacons(
            templates_root_dir=scan_path,
            ignore_patterns=ignore_patterns,
            template_file_indicators=beacons,
        )
    except Exception as exc:
        msg = f"({type(exc)}) Error counting templates. Details: {exc}"
        log.error(msg)

        raise
    
    log.debug(f"Found [{len(categories)}] {'category' if len(categories) == 1 else 'categories'}")
    
    if save_json:
        try:
            io.save_categories_to_json(categories, json_file=json_file)
        except Exception as exc:
            log.error(exc)
            pass
            
    if update_repo_map:
        log.info(f"Update repository map file")
        template_file = "REAMDE.md.j2"
        try:
            context = {"categories": categories}
            log.info(f"Rendering Jinja2 template '{template_file}' from directory '{REPO_MAP_TEMPLATE_DIR}' to '{REPO_MAP_OUTPUT_DIR}'")
            render_jinja_template(
                template_dir=REPO_MAP_TEMPLATE_DIR,
                template_file="README.md.j2",
                output_dir=REPO_MAP_OUTPUT_DIR,
                context=context,
                dry_run=False
            )
        except Exception as exc:
            log.error(exc)
            pass
