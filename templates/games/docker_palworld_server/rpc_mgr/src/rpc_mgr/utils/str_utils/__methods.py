from __future__ import annotations

def format_seconds_to_timestr(seconds: int) -> str:
    """Converts an integer number of seconds into a human-readable duration string.

    Args:
        seconds (int): The number of seconds to convert.

    Returns:
        str: A human-readable duration string.

    """
    if seconds < 60:
        return f"{seconds} second{'s' if seconds != 1 else ''}"
    
    minutes, seconds = divmod(seconds, 60)
    if minutes < 60:
        return f"{minutes} minute{'s' if minutes != 1 else ''}"
    
    hours, minutes = divmod(minutes, 60)
    if hours < 24:
        return f"{hours} hour{'s' if hours != 1 else ''}"
    
    days, hours = divmod(hours, 24)
    if days < 7:
        return f"{days} day{'s' if days != 1 else ''}"
    
    weeks, days = divmod(days, 7)
    if weeks < 52:
        return f"{weeks} week{'s' if weeks != 1 else ''}"
    
    years, weeks = divmod(weeks, 52)
    return f"{years} year{'s' if years != 1 else ''}"
