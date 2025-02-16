from __future__ import annotations

import sys

from loguru import logger

def filter_info_debug_warning(record):
    return record["level"].name in ["WARNING", "INFO", "DEBUG"]

def filter_debug_only(record):
    return record["level"].name == "DEBUG"

def filter_error_only(record):
    return record["level"].name == "ERROR"

def filter_trace_only(record):
    return record["level"].name == "TRACE"

def filter_all_errors(record):
    return record["level"].name in ["ERROR", "TRACE"]

def setup_logging(
    log_level: str = "INFO",
    log_fmt: str = "{time:YYYY-MM-DD HH:mm:ss} | [{level}] | ({module}.{function}:{line}) | > {message}",
    enable_loggers: list[str] = ["weathersched"],
    add_file_logger: bool = False,
    add_error_file_logger: bool = False,
    colorize: bool = False
):
    
    default_fmt = "{time:YYYY-MM-DD HH:mm:ss} | [{level}] | ({module}.{function}:{line}) | > {message}"
    color_fmt = "<yellow>{time:YYYY-MM-DD HH:mm:ss}</yellow> | [<cyan>{level}</cyan>] | <blue>({module}.{function}:{line})</blue> | > {message}"
    
    logger.remove(0)
    logger.add(
        sys.stderr,
        format=color_fmt if colorize else log_fmt,
        level=log_level,
        colorize=colorize
    )

    if enable_loggers:
        for _logger in enable_loggers:
            logger.enable(_logger)
            

    if add_file_logger:
        logger.add("logs/app.log", filter=filter_info_debug_warning, format=default_fmt, retention=3, rotation="15 MB", level="DEBUG")
        
    if add_error_file_logger:
        logger.add("logs/error.log", format=default_fmt, filter=filter_all_errors,retention=3, rotation="15 MB", level="ERROR")
