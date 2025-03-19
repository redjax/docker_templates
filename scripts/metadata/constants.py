__all__ = [
    "TEMPLATES_ROOT",
    "JINJA_TEMPLATE_DIR",
    "OUTPUT_DIR",
    "IGNORE_CATEGORY_NAMES_FILE",
    "TEMPLATE_INDICATORS",
    "TEMPLATE_BEACONS",
    "CATEGORIES_METADATA_FILE",
]

TEMPLATES_ROOT: str = "templates"
JINJA_TEMPLATE_DIR: str = "map/_template"
OUTPUT_DIR: str = "map"
IGNORE_CATEGORY_NAMES_FILE: str = "metadata/ignore_categories"
TEMPLATE_INDICATORS: str = ["*.env", "compose.yml", "docker-compose.yml", "*.env.example"]
TEMPLATE_BEACONS: dict = {"category": ".category", "docker_template": ".docker-compose.template", "cookiecutter_template": ".cookiecutter.template"}
CATEGORIES_METADATA_FILE: str = "metadata/categories.json"
