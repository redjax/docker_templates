from __future__ import annotations

import logging
from pathlib import Path
import sys

## Add parent directory to PYTHONPATH dynamically
sys.path.append(str(Path(__file__).resolve().parent.parent))

log = logging.getLogger(__name__)

from metadata.main import run
    
if __name__ == "__main__":
    run()
