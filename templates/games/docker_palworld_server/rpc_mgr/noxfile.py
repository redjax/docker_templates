from __future__ import annotations

from contextlib import contextmanager
import importlib.util
import logging
import os
from pathlib import Path
import platform
import shutil
import socket
import sys
import typing as t

log = logging.getLogger(__name__)

import nox

## Set nox options
if importlib.util.find_spec("uv"):
    nox.options.default_venv_backend = "uv|virtualenv"
else:
    nox.options.default_venv_backend = "virtualenv"
nox.options.reuse_existing_virtualenvs = True
nox.options.error_on_external_run = False
nox.options.error_on_missing_interpreters = False
# nox.options.report = True

## Instruct PDM to use nox's Python
os.environ.update({"UV_NO_CACH": "1"})

## Define versions to test
PY_VERSIONS: list[str] = ["3.12", "3.11"]
## Get tuple of Python ver ('maj', 'min', 'mic')
PY_VER_TUPLE: tuple[str, str, str] = platform.python_version_tuple()
## Dynamically set Python version
DEFAULT_PYTHON: str = f"{PY_VER_TUPLE[0]}.{PY_VER_TUPLE[1]}"


# this VENV_DIR constant specifies the name of the dir that the `dev`
# session will create, containing the virtualenv;
# the `resolve()` makes it portable
VENV_DIR = Path("./.venv").resolve()

## At minimum, these paths will be checked by your linters
#  Add new paths with nox_utils.append_lint_paths(extra_paths=["..."],)
DEFAULT_LINT_PATHS: list[str] = ["src/", "tests/", "scripts/", "notebooks/", "sandbox"]
## Python app source code
APP_SRC: str = "src/transmissionpy"
## Set directory for requirements.txt file output
REQUIREMENTS_OUTPUT_DIR: Path = Path("./")

logging.basicConfig(
    level="DEBUG",
    format="%(name)s | [%(levelname)s] > %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

for _logger in []:
    logging.getLogger(_logger).setLevel("WARNING")


@contextmanager
def cd(newdir):
    """Context manager to change a directory before executing command."""
    prevdir = os.getcwd()
    os.chdir(os.path.expanduser(newdir))
    try:
        yield
    finally:
        os.chdir(prevdir)
        
def find_free_port(host_addr: str = "0.0.0.0", start_port=8000) -> int:
    """Find a free port starting from a specific port number.

    Params:
        host_addr (str): The host address to bind to. Default is '0.0.0.0', which can be dangerous.
        start_port (int): Attempt to bind to this port, and increment 1 each time port binding fails.

    Returns:
        (int): An open port number, i.e. 8000 if 8001 is in use.

    """
    port: int = start_port

    ## Loop open port check until one is bound
    while True:
        ## Create a socked
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            try:
                ## Try binding port to host address
                sock.bind((host_addr, port))
                return port

            except socket.error:
                ## Port in use, increment & retry
                log.info(f"Port {port} is in use, trying the next port.")
                port += 1

def install_uv_project(session: nox.Session, external: bool = False) -> None:
    """Method to install uv and the current project in a nox session."""
    log.info("Installing uv in session")
    session.install("uv")
    log.info("Syncing uv project")
    session.run("uv", "sync", external=external)
    log.info("Installing project")
    session.run("uv", "pip", "install", ".", external=external)
    
##############
# Repository #
##############


@nox.session(python=[DEFAULT_PYTHON], name="dev-env")
def dev(session: nox.Session) -> None:
    """Sets up a python development environment for the project.

    This session will:
    - Create a python virtualenv for the session
    - Install the `virtualenv` cli tool into this environment
    - Use `virtualenv` to create a global project virtual environment
    - Invoke the python interpreter from the global project environment to install
      the project and all it's development dependencies.
    """
    install_uv_project(session)
    

@nox.session(python=[DEFAULT_PYTHON], name="ruff-lint", tags=["ruff", "clean", "lint"])
def run_linter(session: nox.Session, lint_paths: list[str] = DEFAULT_LINT_PATHS):
    """Nox session to run Ruff code linting."""
    if not Path("ruff.toml"):
        if not Path("pyproject.toml").exists():
            log.warning(
                """No ruff.toml file found. Make sure your pyproject.toml has a [tool.ruff] section!
                    
If your pyproject.toml does not have a [tool.ruff] section, ruff's defaults will be used.
Double check imports in __init__.py files, ruff removes unused imports by default.
"""
            )

    session.install("ruff")

    log.info("Linting code")
    for d in lint_paths:
        if not Path(d).exists():
            log.warning(f"Skipping lint path '{d}', could not find path")
            pass
        else:
            lint_path: Path = Path(d)
            log.info(f"Running ruff imports sort on '{d}'")
            session.run(
                "ruff",
                "check",
                lint_path,
                "--select",
                "I",
                "--fix",
            )

            log.info(f"Running ruff checks on '{d}' with --fix")
            session.run(
                "ruff",
                "check",
                lint_path,
                "--fix",
            )

    log.info("Linting noxfile.py")
    session.run(
        "ruff",
        "check",
        f"{Path('./noxfile.py')}",
        "--fix",
    )


@nox.session(python=[DEFAULT_PYTHON], name="uv-export")
@nox.parametrize("requirements_output_dir", REQUIREMENTS_OUTPUT_DIR)
def export_requirements(session: nox.Session, requirements_output_dir: Path):
    ## Ensure REQUIREMENTS_OUTPUT_DIR path exists
    if not requirements_output_dir.exists():
        try:
            requirements_output_dir.mkdir(parents=True, exist_ok=True)
        except Exception as exc:
            msg = Exception(
                f"Unable to create requirements export directory: '{requirements_output_dir}'. Details: {exc}"
            )
            log.error(msg)

            requirements_output_dir: Path = Path("./")

    session.install(f"uv")

    log.info("Exporting production requirements")
    session.run(
        "uv",
        "pip",
        "compile",
        "pyproject.toml",
        "-o",
        str(REQUIREMENTS_OUTPUT_DIR / "requirements.txt"),
    )


###############
# Code checks #
###############


@nox.session(python=[DEFAULT_PYTHON], name="vulture-check", tags=["quality"])
def run_vulture_check(session: nox.Session):
    session.install(f"vulture")

    log.info("Checking for dead code with vulture")
    session.run("vulture", APP_SRC, "--min-confidence", "100")

@nox.session(python=[DEFAULT_PYTHON], name="detect-secrets", tags=["quality"])
def scan_for_secrets(session: nox.Session):
    session.install("detect-secrets")

    log.info("Scanning project for secrets")
    session.run("detect-secrets", "scan")
    
@nox.session(python=[DEFAULT_PYTHON], name="radon-code-complexity", tags=["quality"])
def radon_code_complexity(session: nox.Session):
    session.install("radon")

    log.info("Getting code complexity score")
    session.run(
        "radon",
        "cc",
        APP_SRC,
        "-s",
        "-a",
        "--total-average",
        "-nc",
        # "-j",
        # "-O",
        # "radon_complexity_results.json",
    )


@nox.session(python=[DEFAULT_PYTHON], name="radon-raw", tags=["quality"])
def radon_raw(session: nox.Session):
    session.install("radon")

    log.info("Running radon raw scan")
    session.run(
        "radon",
        "raw",
        APP_SRC,
        "-s",
        # "-j",
        # "-O",
        # "radon_raw_results.json"
    )


@nox.session(python=[DEFAULT_PYTHON], name="radon-maintainability", tags=["quality"])
def radon_maintainability(session: nox.Session):
    session.install("radon")

    log.info("Running radon maintainability scan")
    session.run(
        "radon",
        "mi",
        APP_SRC,
        "-n",
        "C",
        "-x",
        "F",
        "-s",
        # "-j",
        # "-O",
        # "radon_maitinability_results.json",
    )


@nox.session(python=[DEFAULT_PYTHON], name="radon-halstead", tags=["quality"])
def radon_halstead(session: nox.Session):
    session.install("radon")

    log.info("Running radon Halstead metrics scan")
    session.run(
        "radon",
        "hal",
        APP_SRC,
        "-f",
        # "-j",
        # "-O",
        # "radon_halstead_results.json",
    )


@nox.session(python=[DEFAULT_PYTHON], name="xenon", tags=["quality"])
def xenon_scan(session: nox.Session):
    session.install("xenon")

    log.info("Scanning complexity with xenon")
    try:
        session.run("xenon", "-b", "B", "-m", "C", "-a", "C", APP_SRC)
    except Exception as exc:
        log.warning(
            f"\nNote: For some reason, this always 'fails' with exit code 1. Xenon still works when running in a Nox session, it seems this error can be ignored."
        )
