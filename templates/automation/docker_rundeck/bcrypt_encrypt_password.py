# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "bcrypt",
# ]
# ///
"""Script to encrypt a password with bcrypt.

Description:
    It is insecure to store plaintext passwords, i.e. in .env files for Docker.
    This script prompts for a password, encrypts it with bcrypt, and returns the encrypted password.

    It can also save the encrypted password to a file. If you save your password to a file, you should not
    store that file beyond copying the encrypted password into an environment or vault.

Usage:
    python bcrypt_encrypt_password.py [options]

Options:
    -d, --debug         Enable debug logging
    -n, --no-print      Do not print the password. Use with -o/--output <filename> to save to a file and skip printing to the console.
    -p, --password      The password to encrypt. If not provided, script will prompt for input.
    -s, --save          Save the encrypted password to a file (default: bcryptpass)
    -o, --output        File to save the encrypted password to (default: bcryptpass)

Example:
    python bcrypt_encrypt_password.py -p "my_password" -s -o rundeck_admin

"""

import logging
import importlib.util
import getpass
import argparse
from pathlib import Path
import re

log = logging.getLogger(__name__)

## Check if Python bcrypt package is installed
if not importlib.util.find_spec("bcrypt"):
    log.error(
        "bcrypt is not installed. Install with 'pip install bcrypt'. If you are using uv, you can run '"
    )
    exit(1)

import bcrypt  # noqa: E402


def parse_args() -> argparse.Namespace:
    """Parse CLI args.

    Returns:
        argparse.Namespace: Parsed arguments.
    """
    ## Initialize parser
    parser = argparse.ArgumentParser(
        usage="%(prog)s [options]",
        description="Encrypt a password with bcrypt. Useful for storing secrets in plaintext files.",
    )

    ## Enable/disable debug logging
    parser.add_argument(
        "-d", "--debug", action="store_true", help="Enable debug logging"
    )
    ## Enable/disable printing encrypted password to the console
    parser.add_argument(
        "-n",
        "--no-print",
        action="store_true",
        help="Do not print the password. Use with -o/--output <filename> to save to a file and skip printing to the console.",
    )
    ## Accept the password to encrypt from the CLI
    parser.add_argument(
        "-p",
        "--password",
        type=str,
        help="The password to encrypt. If not provided, script will prompt for input.",
    )
    ## Save the encrypted password to a file. Default: ./bcryptpass
    parser.add_argument(
        "-s",
        "--save",
        action="store_true",
        help="Save the encrypted password to a file (default: bcryptpass)",
    )
    ## Override the output filepath/name
    parser.add_argument(
        "-o",
        "--output",
        type=str,
        default="bcryptpass",
        help="File to save the encrypted password to",
    )

    return parser.parse_args()


def is_bcrypt_hash(hash_str) -> bool:
    """Test a string to see if it is a bcrypt hash.

    Params:
        hash_str (str): The string to test.

    Returns:
        bool: True if the string is a bcrypt hash, False otherwise.
    """
    ## Build regex to match bcrypt hashes
    bcrypt_pattern = re.compile(r"^\$2[aby]\$\d{2}\$[./A-Za-z0-9]{53}$")

    ## Return True if string appears to be bcrypt-encrypted
    return bool(bcrypt_pattern.match(hash_str))


def hash_password(input_password: bytes) -> str:
    """Return a bcrypt-encrypted password.

    Params:
        input_password (str): The password to encrypt.

    Returns:
        str: The bcrypt-encrypted password.
    """
    if not input_password:
        log.error(
            "Input password is required. Pass one with -p/--password <password> from the CLI, or input a password when prompted."
        )
        exit(1)

    ## Create hash from input password
    hashed_password = bcrypt.hashpw(input_password, bcrypt.gensalt())

    return hashed_password


def save_password(password: bytes, output_file: str) -> bool:
    """Save an encrypted password to a file.

    Params:
        password (str): The password to encrypt.
        output_file (str): The file to save the encrypted password to.

    Returns:
        bool: True if successful, False otherwise.
    """

    if Path(output_file).exists():
        log.warning(f"Path '{output_file}' already exists.")
        _continue: bool = input("Continue anyway? (y/n): ").lower() == "y"

        if not _continue:
            log.info("Exiting.")
            exit(0)

    log.info(f"Saving password to file: {output_file}")
    try:

        with open(output_file, "wb") as f:
            f.write(password.decode("utf-8"))
    except Exception as e:
        log.warning(f"Error saving password to file: {e}")
        return False

    log.info(f"Saved hashed password to {output_file}")

    return True


if __name__ == "__main__":
    args = parse_args()

    logging.basicConfig(
        level="DEBUG" if args.debug else "INFO",
        format=(
            "%(asctime)s - %(levelname)s - [%(name)s:%(lineno)s] - %(message)s"
            if args.debug
            else "[%(levelname)s] %(message)s"
        ),
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    log.debug("DEBUG logging enabled.")

    if not args.password:
        ## Prompt user for password if none was passed with -p/--password
        password = getpass.getpass("Enter password: ")
    else:
        password = args.password

    ## Create hashed password
    hashed_password = hash_password(input_password=password.encode("utf-8"))

    if args.save:
        ## Save password to file
        save_password(password=hashed_password, output_file=args.output)

    if not args.no_print:
        ## Print hashed password if not disabled
        log.info(f"Hashed password:\n{hashed_password.decode('utf-8')}")
