import subprocess
import logging
import argparse

log = logging.getLogger(__name__)

def parse_args():
    parser = argparse.ArgumentParser("paperless-backup")
    
    parser.add_argument("-d", "--debug", action="store_true", help="Enable debug logging")
    
    args = parser.parse_args()
    
    return args


def check_docker_installed():
    try:
        result = subprocess.run(
            ["docker", "--version"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        return result.returncode == 0
    except FileNotFoundError:
        return False


def check_compose_installed():
    try:
        result = subprocess.run(
            ["docker", "compose", "version"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        if result.returncode == 0:
            return True
    except FileExistsError:
        return False    


def main(args: argparse.Namespace):
    log_level: str = "DEBUG" if args.debug else "INFO"
    log_fmt: str = "%(asctime)s | %(levelname)s | %(module)s.%(funcName)s:%(lineno)s :: %(message)s" if args.debug else "%(asctime)s | %(levelname)s :: %(message)s"
    log_datefmt: str = "%Y-%m-%d %H:%M:%S" if args.debug else "%H:%M"
    
    logging.basicConfig(level=log_level, format=log_fmt, datefmt=log_datefmt)
    log.debug("DEBUG logging enabled")
    
    docker_installed = check_docker_installed()
    compose_installed = check_compose_installed()
    
    log.debug(f"Found Docker: {docker_installed}")
    log.debug(f"Found Docker Compose: {compose_installed}")
    
    if docker_installed and compose_installed:
        log.info("Found Docker and Docker Compose")
    elif docker_installed and not compose_installed:
        log.error("Found Docker, but Docker Compose is not installed")
        exit(1)
    elif not docker_installed and compose_installed:
        log.error("Docker is not installed, but found Doccker Compose")
        exit(1)
    else:
        log.error("Could not find Docker or Docker Compose")
        exit(1)


if __name__ == "__main__":
    args = parse_args()
    
    main(args)
