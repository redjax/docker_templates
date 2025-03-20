import sys
from pathlib import Path
import logging

log = logging.getLogger(__name__)

## Add parent directory to PYTHONPATH dynamically
sys.path.append(str(Path("./scripts/metadata/").resolve()))

from scripts.metadata import run

if __name__ == "__main__":
    run()
