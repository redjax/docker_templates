import logging
import sys
from pathlib import Path

## Add parent directory to PYTHONPATH dynamically
sys.path.append(str(Path(__file__).resolve().parent.parent))

log = logging.getLogger(__name__)

from metadata.main import run
    
if __name__ == "__main__":
    run()
