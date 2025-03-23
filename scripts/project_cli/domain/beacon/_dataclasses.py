from __future__ import annotations

from dataclasses import dataclass
import logging
from pathlib import Path

log = logging.getLogger(__name__)

__all__ = ["BeaconFile"]

@dataclass
class BeaconFile():
    friendly_name: str
    beacon: str
    beacon_path: str
    
    @property
    def path(self) -> Path:
        return Path(str(self.beacon_path)).expanduser() if "~" in self.beacon else Path(str(self.beacon_path))    
    