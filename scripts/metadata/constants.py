__all__ = [
    "TEMPLATES_ROOT",
    "JINJA_TEMPLATE_DIR",
    "OUTPUT_DIR",
    "IGNORE_CATEGORY_NAMES_FILE",
    "TEMPLATE_INDICATORS",
    "TEMPLATE_BEACONS",
    "CATEGORIES_METADATA_FILE",
    "METADATA_DIR",
    "IGNORE_COUNT_PATTERNS_FILE"
]

TEMPLATES_ROOT: str = "templates"
JINJA_TEMPLATE_DIR: str = "map/_template"
OUTPUT_DIR: str = "map"
METADATA_DIR: str = "metadata"
IGNORE_CATEGORY_NAMES_FILE: str = f"{METADATA_DIR}/ignore_categories"
TEMPLATE_INDICATORS: str = ["*.env", "compose.yml", "docker-compose.yml", "*.env.example"]
TEMPLATE_BEACONS: dict = {"category": ".category", "docker_template": ".docker-compose.template", "cookiecutter_template": ".cookiecutter.template"}
CATEGORIES_METADATA_FILE: str = f"{METADATA_DIR}/categories.json"
## Directory/file patterns to ignore during discovery
IGNORE_COUNT_PATTERNS_FILE: list[str] = f"{METADATA_DIR}/ignore_in_count"
