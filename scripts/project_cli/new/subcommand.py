from __future__ import annotations

import argparse
import json
import logging
from pathlib import Path

from project_cli import io, search
from project_cli.constants import (
    IGNORE_IN_COUNT,
    METADATA_DIR,
    REPO_MAP_OUTPUT_DIR,
    REPO_MAP_TEMPLATE_DIR,
    TEMPLATE_BEACONS_DICT,
    TEMPLATES_METADATA_CSV_FILE,
    TEMPLATES_METADATA_JSON_FILE,
    TEMPLATES_ROOT,
)
from project_cli.new.methods import new_docker_template

log = logging.getLogger(__name__)

__all__ = ["parse_arguments"]

TEMPLATES_ROOT: str = "./templates"
DEFAULT_COOKIECUTTER_TEMPLATE: str = f"{TEMPLATES_ROOT}/_cookiecutter/docker-template"


def parse_arguments(subparsers):
    new_parser = subparsers.add_parser("new", help="Entrypoint for creating new entities, i.e. a new template")
    new_parser.set_defaults(func=_new)
    
    ## Subparsers for the 'new' command
    new_subparsers = new_parser.add_subparsers(dest="subcommand", required=True)
    
    template_subparser = new_subparsers.add_parser("template", help="CCreate a new Docker Compose template")
    
    template_subparser.add_argument("--category", type=str, default=None, help="The category for the new template. This is the directory in templates/<category_name> where the template will be created.")
    
    template_subparser.add_argument("--cookiecutter-template", type=str, default=DEFAULT_COOKIECUTTER_TEMPLATE, help="Path to the cookiecutter template to render.")
    
    template_subparser.set_defaults(func=_new_template)
    


def _new_template(args):
    # Perform the functionality for 'new template'
    log.debug(f"Handling 'new template' subcommand with arguments: {args}")
    
    # Example logic for creating a new Docker Compose template
    category = args.category or "default-category"
    cookiecutter_template = args.cookiecutter_template
    
    log.info(f"Creating a new Docker Compose template in category '{category}' using cookiecutter template at '{cookiecutter_template}'")
    
    try:
        new_docker_template(template_path=cookiecutter_template)
    except Exception as exc:
        log.error(f"Error rendering cookiecutter template. Details: {exc}")
        return
    

def _new(args):
    if hasattr(args, 'func'):
        args.func(args)
    else:
        log.debug(f"Handling 'new' subcommand with arguments: {args}")