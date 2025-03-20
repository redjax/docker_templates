from pathlib import Path

__all__ = ["is_ignored"]

def is_ignored(
    file: Path, ignore_patterns: list[str], templates_root_dir: Path
) -> bool:
    """Check if a file is inside an ignored directory."""
    relative_path = file.relative_to(templates_root_dir)

    for ignored in ignore_patterns:
        ## Split the ignored path into parts
        ignored_parts = Path(ignored).parts
        ## Check if any part of the relative path contains the ignored directory parts
        if any(part.startswith(ignored_parts[0]) for part in relative_path.parts):
            ## If any part matches, ignore it
            return True

    return False