import typing as t
import argparse
import logging
from pathlib import Path
import csv

log = logging.getLogger(__name__)

TEMPLATES_ROOT: str = "templates"
## File indicators to use for template detection
TEMPLATE_INDICATORS: list[str] = ["compose.yaml", "docker-compose.yaml"]

def parse_arguments():
    parser = argparse.ArgumentParser(description="Find any docker-compose.yaml, compose.yaml file and rename it to 'compose.yml'.")
    
    parser.add_argument("--scan-path", type=str, default=TEMPLATES_ROOT, help="Path to scan for files")
    
    # parser.add_argument("--ignore-pattern", type=str, nargs="*", default=IGNORE_PATTERNS, help="File/path names to ignore")
    
    parser.add_argument("--template-indicator", type=str, nargs="*", default=TEMPLATE_INDICATORS, help="List of template indicators")
    
    ## Set logging level
    parser.add_argument(
        "--log-level",
        type=str,
        default="INFO",
        help="The logging level to use. Default is 'INFO'. Options are: ['NOTSET', 'DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL']",
    )
    
    ## When present, save to CSV
    parser.add_argument(
        "--save-csv",
        action="store_true",
        help="Save the renamed files to a CSV file",
    )
    ## CSV file to save renamed files to
    parser.add_argument(
        "--csv-file",
        type=str,
        default="./metadata/renamed_compose_files.csv",
        help="CSV file to save renamed files to",
    )
    
    ## Dry run, where no actions will be taken
    parser.add_argument("--dry-run", action="store_true", help="Do a dry run, where no real action will be taken.")
    
    ## Parse CLI args
    args = parser.parse_args()

    return args
    

def find_yaml_files(root: str, template_indicators = TEMPLATE_INDICATORS):
    yaml_files: list[str] = []
    
    for p in Path(root).rglob("**/*"):
        if p.name in template_indicators:
            yaml_files.append(str(p))
            
    return yaml_files


def rename_yaml_to_yml(yaml_file: str, dry_run: bool = False):
    p: Path = Path(yaml_file)
    
    new_name = str(p.parent / f"{p.stem}.yml")
    
    if dry_run:
        log.info(f"[DRY RUN] Would rename file '{p}' to '{new_name}'")
        return new_name
    
    log.info(f"Renaming file '{p}' to '{new_name}'")
    try:
        new_path = p.rename(new_name)
        return str(new_path)
    except Exception as exc:
        msg = f"({type(exc)}) Error renaming file '{yaml_file}' to '{new_name}'. Details: {exc}"
        log.error(msg)
        
        return


def save_renamed_files_to_csv(
    renamed_files: list[dict[str, str]], csv_file: str
):
    if not renamed_files:
        log.warning("No data to save as CSV")
        return

    log.info(f"Saving renamed files to CSV file: {csv_file}")

    Path(csv_file).parent.mkdir(parents=True, exist_ok=True)
    with open(csv_file, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=renamed_files[0].keys())
        writer.writeheader()
        writer.writerows(renamed_files)
    log.info(f"Saved CSV: {csv_file}")


def main(root: str, dry_run: bool = False, save_csv: bool = False, csv_file: str = "metadata/renamed_compose_files.csv"):
    yaml_files = find_yaml_files(root=root)
    
    log.info(f"Found [{len(yaml_files)}] .yaml files that should be .yml")
    
    log.debug(f"YAML files: {yaml_files}")
    
    renamed_files: list[dict] = []
    
    for y in yaml_files:
        new_name = rename_yaml_to_yml(y, dry_run=dry_run)
        renamed_files.append({"old": y, "new": new_name})
        
    log.debug(f"Renamed files: {renamed_files}")
    
    if save_csv:
        save_renamed_files_to_csv(renamed_files=renamed_files, csv_file=csv_file)


if __name__ == "__main__":
    ## Parse user's CLI params
    args = parse_arguments()
    
    logging.basicConfig(level=args.log_level.upper() or "INFO", format="%(asctime)s | %(levelname)s |> %(message)s")
    
    log.debug(f"Scan path: {args.scan_path}")
    log.debug(f"Dry run enabled: {args.dry_run}")
    
    try:
        main(root=args.scan_path, dry_run=args.dry_run, save_csv=args.save_csv, csv_file=args.csv_file)
    except Exception as exc:
        msg = f"({type(exc)}) Error scanning for .yaml files. Details: {exc}"
        log.error(msg)
        
        exit(1)