import subprocess
import logging
import argparse

log = logging.getLogger(__name__)

def parse_args():
    parser = argparse.ArgumentParser("paperless-backup")
    
    parser.add_argument("-d", "--debug", action="store_true", help="Enable debug logging")
    
    args = parser.parse_args()
    
    return args


def main(args: argparse.Namespace):
    log_level: str = "DEBUG" if args.debug else "INFO"
    log_fmt: str = "%(asctime)s | %(levelname)s | %(module)s.%(funcName)s:%(lineno)s :: %(message)s" if args.debug else "%(asctime)s | %(levelname)s :: %(message)s"
    log_datefmt: str = "%Y-%m-%d %H:%M:%S" if args.debug else "%H:%M"
    
    logging.basicConfig(level=log_level, format=log_fmt, datefmt=log_datefmt)
    log.debug("DEBUG logging enabled")

if __name__ == "__main__":
    args = parse_args()
    
    main(args)
