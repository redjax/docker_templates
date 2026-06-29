from __future__ import annotations

import argparse
import logging
from pathlib import Path
import sys

log = logging.getLogger(__name__)

## Add parent directory to PYTHONPATH dynamically
sys.path.append(str(Path(__file__).resolve().parent.parent))

from project_cli import count, metadata, new, repo_map
from project_cli.utils import setup

__all__ = ["run"]

def parse_arguments():
    """Parse CLI args passed to the script.

    Returns:
        argparse.Namespace: Parsed CLI args.

    """
    ## Create parser
    parser = argparse.ArgumentParser(description="CLI for controlling repository metadata")
    
    ## Set logging level
    parser.add_argument(
        "--log-level",
        type=str,
        default="INFO",
        help="The logging level to use. Default is 'INFO'. Options are: ['NOTSET', 'DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL']",
    )
    
    ## Initialize subparser to pass into subcommands
    subparsers = parser.add_subparsers(dest="command", help="Available commands")
    
    ## Add subcommands to subparser
    count.parse_arguments(subparsers)
    metadata.parse_arguments(subparsers)
    repo_map.parse_arguments(subparsers)
    new.parse_arguments(subparsers)

    ## Parse CLI args
    args = parser.parse_args()
    
    return args
    

def run():
    args = parse_arguments()
    
    setup.setup_logging(level=args.log_level.upper() or "INFO", fmt=setup.DEBUG_LOGGING_FMT if args.log_level.upper() == "DEBUG" else setup.DEFAULT_LOGGING_FMT)
    
    ## Call the appropriate function based on the subcommand
    if hasattr(args, "func"):
        args.func(args)
    else:
        log.warning("No command provided. Use --help to see usage.")
        return
    

if __name__ == "__main__":
    run()
