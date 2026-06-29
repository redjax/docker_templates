from __future__ import annotations

import logging
from pathlib import Path

import cookiecutter
from cookiecutter.main import cookiecutter  # noqa: F811

log = logging.getLogger(__name__)

TEMPLATES_ROOT: str = "./templates"
COOKIECUTTER_TEMPLATE_PATH: str = f"{TEMPLATES_ROOT}/_cookiecutter/docker-template"


def new_docker_template_page(template_path: str) -> None:
    log.info(
        "Answer the prompts to create a new page in docs/programming/docker/my_containers"
    )


    if not Path(template_path).exists():
        log.warning(
            f"Could not find cookiecutter template at path '{template_path}'."
        )

    while True:
        docs_section_choice = input(
            "Which section directory will the template be exported to (i.e. automation, databases): "
        )

        if docs_section_choice is None or docs_section_choice == "":
            log.warning(
                "You must type a directory name that exists in ./docs/programming/docker/my_containers"
            )

        CONTAINER_SECTION = f"{template_path}/{docs_section_choice}"

        if not Path(CONTAINER_SECTION).exists():
            # mkdir_choice = input(f"[WARNING] Container directory section '{CONTAINER_SECTION}' does not exist. Create directory now? (Y/N): ")
            log.warning(
                f"Could not find section '{CONTAINER_SECTION}'. Creating path '{CONTAINER_SECTION}'"
            )
            try:
                Path(CONTAINER_SECTION).mkdir(parents=True, exist_ok=True)
            except Exception as exc:
                msg = f"({type(exc)}) Error creating section '{CONTAINER_SECTION}'. Details: {exc}"
                log.error(msg)

                raise exc
            
            log.warning(f"Adding .category beacon file to '{CONTAINER_SECTION}'")
            try:
                with open(f"{CONTAINER_SECTION}/.category", "w") as f:
                    pass
            except Exception as exc:
                log.error(f"Failed to create .category beacon file at path '{CONTAINER_SECTION}/.category'. Details: {exc}")
                raise

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

if __name__ == "__main__":
    logging.basicConfig(level="INFO", format="%(msg)s", datefmt="%Y-%m-%d %H:%M:%S")
    
    new_docker_template_page(template_path=TEMPLATES_ROOT)