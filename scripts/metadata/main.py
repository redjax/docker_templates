import logging
from pathlib import Path
import typing as t
import sys
import argparse

log = logging.getLogger(__name__)

## Add parent directory to PYTHONPATH dynamically
sys.path.append(str(Path(__file__).resolve().parent.parent))

from metadata.domain import beacon as beacon_domain
from metadata.utils import setup
from metadata import count, beacons

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
    count.parse_arguments(subparsers)

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
