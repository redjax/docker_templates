import logging

log = logging.getLogger(__name__)

__all__ = ["DEFAULT_LOGGING_FMT", "DEBUG_LOGGING_FMT", "DEFAULT_DATE_FMT", "setup_logging"]

DEFAULT_LOGGING_FMT: str = "%(asctime)s | %(levelname)s |> %(message)s"
DEBUG_LOGGING_FMT: str = "%(asctime)s | %(levelname)s | %(name)s.%(funcName)s:%(lineno)d |> %(message)s"
DEFAULT_DATE_FMT: str = "%Y-%m-%d %H:%M:%S"


def setup_logging(level: str = "INFO", fmt: str = DEFAULT_LOGGING_FMT, datefmt: str = DEFAULT_DATE_FMT):
    logging.basicConfig(
        level=level,
        format=fmt,
        datefmt=datefmt,
    )
