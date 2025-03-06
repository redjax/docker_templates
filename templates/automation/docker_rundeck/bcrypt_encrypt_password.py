# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "bcrypt",
# ]
# ///

import logging
import importlib.util
import getpass

log = logging.getLogger(__name__)
logging.basicConfig(level="DEBUG", format="%(asctime)s - %(levelname)s - [%(name)s:%(lineno)s] - %(message)s", datefmt="%Y-%m-%d %H:%M:%S")

if not importlib.util.find_spec("bcrypt"):
    log.error("bcrypt is not installed. Install with 'pip install bcrypt'. If you are using uv, you can run '")
    exit(1)

import bcrypt


def hash_password():
    password = getpass.getpass("Enter password: ")
    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(password.encode("utf-8"), salt)
    return hashed_password

if __name__ == "__main__":
    hashed_password = hash_password()
    print("Hashed password:", hashed_password.decode("utf-8"))
