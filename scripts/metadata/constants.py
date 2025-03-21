from __future__ import annotations

__all__ = [
    "TEMPLATES_ROOT",
    "REPO_MAP_TEMPLATE_DIR",
    "REPO_MAP_OUTPUT_DIR",
    "METADATA_DIR",
    "CATEGORIES_METADATA_JSON_FILE",
    "TEMPLATES_METADATA_JSON_FILE",
    "TEMPLATES_METADATA_CSV_FILE",
    "TEMPLATES_COUNT_FILE",
    "DOCKER_TEMPLATE_INDICATORS",
    "TEMPLATE_BEACONS_DICT",
    "TEMPLATE_BEACONS",
    "IGNORE_TEMPLATE_CATEGORIES",
    "IGNORE_IN_COUNT",
]

TEMPLATES_ROOT: str = "templates"
REPO_MAP_TEMPLATE_DIR: str = "map/_template"
REPO_MAP_OUTPUT_DIR: str = "map"
METADATA_DIR: str = "metadata"
CATEGORIES_METADATA_JSON_FILE: str = f"{METADATA_DIR}/categories.json"
TEMPLATES_METADATA_JSON_FILE: str = f"{METADATA_DIR}/templates.json"
TEMPLATES_METADATA_CSV_FILE: str = f"{METADATA_DIR}/templates.csv"
TEMPLATES_COUNT_FILE: str = f"{METADATA_DIR}/templates_count"

DOCKER_TEMPLATE_INDICATORS: str = ["*.env", "compose.yml", "docker-compose.yml", "*.env.example"]
TEMPLATE_BEACONS_DICT: dict = {"category": {"beacon": ".category", "friendly_name": "Template category directory"}, "docker_template": {"beacon": ".docker-compose.template", "friendly_name": "Docker Compose template"}, "cookiecutter_template": {"beacon": ".cookiecutter.template", "friendly_name": "Cookiecutter template"}}
TEMPLATE_BEACONS: list[str] = [v["beacon"] for k, v in TEMPLATE_BEACONS_DICT.items()]

IGNORE_TEMPLATE_CATEGORIES: list[str] = []
IGNORE_IN_COUNT: list[str] = ["_cookiecutter"]
