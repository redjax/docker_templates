from __future__ import annotations

import logging
from pathlib import Path
import typing as t

import cookiecutter

log = logging.getLogger(__name__)

__all__ = ["new_docker_template"]

def new_docker_template(
    template_path: str,
    template_category: t.Optional[str] = None,
    template_name: t.Optional[str] = None,
    template_shortname: t.Optional[str] = None,
    template_summary: t.Optional[str] = None,
    template_description: t.Optional[str] = None
) -> None:
    log.info(
        "Answer the prompts to create a new page in docs/programming/docker/my_containers"
    )


    if not Path(template_path).exists():
        log.warning(
            f"Could not find cookiecutter template at path '{template_path}'."
        )

    if template_category is None or template_category == "":
        log.warning("No template category detected, prompting for category")

        while True:
            template_category = input(
                "Which section directory will the template be exported to (i.e. automation, databases): "
            )

            if template_category is None or template_category == "":
                log.warning(
                    "You must type a directory name that exists in ./docs/programming/docker/my_containers"
                )

            break
        
    CONTAINER_SECTION = f"{template_path}/{template_category}"

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

    cookiecutter_context = {
        "template_name": template_name,
        "template_shortname": template_shortname,
        "template_summary": template_summary,
        "template_description": template_description
    }
    cookiecutter_context = {k: v for k, v in cookiecutter_context.items() if v is not None}
    log.debug(f"Cookiecutter context: {cookiecutter_context}")

    log.info(
        f"Rendering template [{template_path}] to [{CONTAINER_SECTION}]"
    )

    try:
        cookiecutter(
            template=str(template_path),
            output_dir=str(CONTAINER_SECTION),
            no_input=False,
        )
    except Exception as exc:
        msg = f"({type(exc)}) Error rendering template. Details: {exc}"
        log.error(msg)