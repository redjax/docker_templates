from __future__ import annotations

import subprocess

from loguru import logger as log

def execute_command(
    command: list[str],
    capture_output: bool = True,
    text: bool = True,
    check: bool = True,
) -> subprocess.CompletedProcess:
    """Execute a shell command and return the output.

    Params:
        command (list[str]): The command to execute as a list of strings.
        capture_output (bool): Whether to capture standard output and error.
        text (bool): If True, return the output as a string. If False, return bytes.
        check (bool): If True, raise CalledProcessError on a non-zero exit code.

    Returns:
        str: The command's standard output.

    Raises:
        subprocess.CalledProcessError: If the command fails and `check` is True.

    """
    log.debug(f"Executing command: {' '.join(command)}")
    try:
        result: subprocess.CompletedProcess = subprocess.run(
            command, capture_output=capture_output, text=text, check=check
        )
        log.debug(f"Command output: {result.stdout.strip()}")
        return result
    except subprocess.CalledProcessError as exc:
        log.error(
            f"Command failed with exit code {exc.returncode}. Error: {exc.stderr}"
        )
        raise
