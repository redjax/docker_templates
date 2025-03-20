import logging

log = logging.getLogger(__name__)

__all__ = ["load_ignored_patterns"]

def load_ignored_patterns(ignore_patterns_file: str):
    log.debug(f"Loading ignored patterns from file: {ignore_patterns_file}")
    try:
        with open(ignore_patterns_file, "r") as f:
            ignored_patterns = f.read().splitlines()
            
        log.debug(f"Ignored patterns: {ignored_patterns}")
        
        return ignored_patterns
    except IOError as e:
        log.error(f"Error reading ignore patterns from file '{ignore_patterns_file}'.")
        raise
    except PermissionError as perm_err:
        log.error(f"Permission denied reading ignored patterns file at path '{ignore_patterns_file}'")
        raise
    except Exception as exc:
        log.error(f"({type(exc)}) Error reading ignore patterns from file '{ignore_patterns_file}'. Details: {exc}")
        raise
    