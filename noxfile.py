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
DEFAULT_LINT_PATHS: list[str] = ["scripts"]
## Set directory for requirements.txt file output
REQUIREMENTS_OUTPUT_DIR: Path = Path("./")

## Configure logging
logging.basicConfig(
    level="DEBUG",
    format="%(name)s | [%(levelname)s] > %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

## Add logger names to the list to 'silence' them, reducing log noise from 3rd party packages
for _logger in []:
    logging.getLogger(_logger).setLevel("WARNING")


@contextmanager
def cd(new_dir) -> t.Generator[None, t.Any, None]:  # type: ignore
    """Context manager to change a directory before executing command."""
    prev_dir: str = os.getcwd()
    os.chdir(os.path.expanduser(new_dir))
    try:
        yield
    finally:
        os.chdir(prev_dir)


def install_uv_project(session: nox.Session, external: bool = False) -> None:
    """Method to install uv and the current project in a nox session."""
    log.info("Installing uv in session")
    session.install("uv")
    log.info("Syncing uv project")
    session.run("uv", "sync", external=external)
    log.info("Installing project")
    session.run("uv", "pip", "install", ".", external=external)


def find_free_port(start_port=8000) -> int:
    """Find a free port starting from a specific port number."""
    port = start_port
    while True:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            try:
                sock.bind(("0.0.0.0", port))
                return port
            except socket.error:
                log.info(f"Port {port} is in use, trying the next port.")
                port += 1


@nox.session(python=[DEFAULT_PYTHON], name="dev-env")
def dev(session: nox.Session) -> None:
    """Sets up a python development environment for the project.

    Run this on a fresh clone of the repository to automate building the project with uv.
    """
    install_uv_project(session, external=True)


@nox.session(python=[DEFAULT_PYTHON], name="lint", tags=["clean", "lint"])
def run_linter(
    session: nox.Session, lint_paths: list[str] = DEFAULT_LINT_PATHS
) -> None:
    """Nox session to run black code linting."""
    session.install("black")

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
        "black",
        f"{Path('./noxfile.py')}",
    )


@nox.session(python=[DEFAULT_PYTHON], name="update-template-counts")
def update_template_count(session: nox.Session) -> None:
    install_uv_project(session)
    session.install("pandas", "pyarrow")

    log.info("Counting templates")
    session.run("uv", "run", "scripts/count_templates.py", "--update-all")


##############
# Pre-commit #
##############


@nox.session(python=PY_VERSIONS, name="pre-commit-all")
def run_pre_commit_all(session: nox.Session) -> None:
    session.install("pre-commit")
    session.run("pre-commit")

    log.info("Running all pre-commit hooks")
    session.run("pre-commit", "run")


@nox.session(python=PY_VERSIONS, name="pre-commit-update")
def run_pre_commit_autoupdate(session: nox.Session) -> None:
    session.install("pre-commit")

    log.info("Running pre-commit autoupdate")
    session.run("pre-commit", "autoupdate")


@nox.session(python=PY_VERSIONS, name="pre-commit-nbstripout")
def run_pre_commit_nbstripout(session: nox.Session) -> None:
    session.install("pre-commit")

    log.info("Running nbstripout pre-commit hook")
    session.run("pre-commit", "run", "nbstripout")


##########
# MKDocs #
##########


@nox.session(python=[DEFAULT_PYTHON], name="publish-mkdocs", tags=["mkdocs", "publish"])
def publish_mkdocs(session: nox.Session) -> None:
    install_uv_project(session)

    log.info("Publishing MKDocs site to Github Pages")

    session.run("mkdocs", "gh-deploy")


@nox.session(
    python=[DEFAULT_PYTHON], name="serve-mkdocs-check-links", tags=["mkdocs", "lint"]
)
def check_mkdocs_links(session: nox.Session) -> None:
    install_uv_project(session)

    free_port = find_free_port(start_port=8000)

    log.info(f"Serving MKDocs site with link checking enabled on port {free_port}")
    try:
        os.environ["ENABLED_HTMLPROOFER"] = "true"
        session.run("mkdocs", "serve", "--dev-addr", f"0.0.0.0:{free_port}")
    except Exception as exc:
        msg = f"({type(exc)}) Unhandled exception checking mkdocs site links. Details: {exc}"
        log.error(msg)

        raise exc


@nox.session(python=DEFAULT_PYTHON, name="serve-mkdocs", tags=["mkdocs", "serve"])
def serve_mkdocs(session: nox.Session) -> None:
    install_uv_project(session)

    free_port = find_free_port(start_port=8000)

    log.info(f"Serving MKDocs site on port {free_port}")

    try:
        session.run("mkdocs", "serve", "--dev-addr", f"0.0.0.0:{free_port}")
    except Exception as exc:
        msg = f"({type(exc)}) Unhandled exception serving MKDocs site. Details: {exc}"
        log.error(msg)


################
# Cookiecutter #
################


@nox.session(
    python=DEFAULT_PYTHON,
    name="new-docker-template",
    tags=["mkdocs", "cookiecutter", "template"],
)
def new_docker_template_page(session: nox.Session) -> None:
    from cookiecutter.main import cookiecutter

    session.install("cookiecutter")

    log.info(
        "Answer the prompts to create a new page in docs/programming/docker/my_containers"
    )

    COOKIECUTTER_TEMPLATE_PATH: Path = Path("./templates/_cookiecutter/docker-template")
    DOCKER_CONTAINER_DOCS_ROOT: Path = Path("./templates")

    if not COOKIECUTTER_TEMPLATE_PATH.exists():
        log.warning(
            f"Could not find cookiecutter template at path '{COOKIECUTTER_TEMPLATE_PATH}'."
        )

    while True:
        docs_section_choice = input(
            "Which section directory will the template be exported to (i.e. automation, databases): "
        )

        if docs_section_choice is None or docs_section_choice == "":
            log.warning(
                "You must type a directory name that exists in ./docs/programming/docker/my_containers"
            )

        CONTAINER_SECTION = DOCKER_CONTAINER_DOCS_ROOT / docs_section_choice

        if not CONTAINER_SECTION.exists():
            # mkdir_choice = input(f"[WARNING] Container directory section '{CONTAINER_SECTION}' does not exist. Create directory now? (Y/N): ")
            log.warning(
                f"Could not find section '{CONTAINER_SECTION}'. Creating path '{CONTAINER_SECTION}'"
            )
            try:
                CONTAINER_SECTION.mkdir(parents=True, exist_ok=True)
            except Exception as exc:
                msg = f"({type(exc)}) Error creating section '{CONTAINER_SECTION}'. Details: {exc}"
                log.error(msg)

                raise exc

        break

    log.info(
        f"Rendering template [{COOKIECUTTER_TEMPLATE_PATH}] to [{CONTAINER_SECTION}]"
    )

    try:
        cookiecutter(
            template=str(COOKIECUTTER_TEMPLATE_PATH),
            output_dir=str(CONTAINER_SECTION),
            no_input=False,
        )
    except Exception as exc:
        msg = f"({type(exc)}) Error rendering template. Details: {exc}"
        log.error(msg)
