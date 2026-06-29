from __future__ import annotations

import logging
from pathlib import Path

log = logging.getLogger(__name__)


def main():
    log.info("Scanning repository for docker-compose.yml files")
    
    compose_files: list[Path] = [p for p in Path(".").rglob("**/docker-compose.yml")] or []
    if len(compose_files) == 0:
        log.warning("No docker-compose.yml files found in repository")
        return
    
    log.info(f"Found [{len(compose_files)}] docker-compose.yml file(s)")
    
    success: list[dict[str, str]] = []
    failure: list[dict[str, str]] = []

    for compose_file in compose_files:
        log.info(f"Renaming {compose_file}")
        try:
            _renamed = compose_file.rename(compose_file.parent / "compose.yaml")
            
            renamed_dict: dict = {"old": str(compose_file), "new": str(_renamed)}
            
            success.append(renamed_dict)
        except Exception as exc:
            msg = f"({type(exc)}) Error renaming {compose_file}. Details: {exc}"
            log.error(msg)
            
            failure.append({"file": str(compose_file), "error": msg})
            
            continue
        
    if len(success) > 0:
        log.info(f"Successfully renamed [{len(success)}] docker-compose.yml file(s)")
        
        for renamed_dict in success:
            log.info(f"Successfully renamed {renamed_dict['old']} to {renamed_dict['new']}")
    
    if len(failure) > 0:
        log.error(f"Failed to rename [{len(failure)}] docker-compose.yml file(s)")
        
        for failure_dict in failure:
            log.error(f"Failed to rename {failure_dict['file']} to {failure_dict['error']}")

if __name__ == "__main__":
    logging.basicConfig(level="DEBUG", format="%(asctime)s - %(levelname)s - %(message)s", datefmt="%Y-%m-%d %H:%M:%S")
    
    main()
