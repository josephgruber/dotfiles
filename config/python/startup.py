import datetime as dt
import json
import math
import os
import sys
import tempfile
from datetime import datetime, timedelta, timezone
from math import *
from pathlib import Path
from uuid import uuid4

try:
    from datetime import UTC
except ImportError:
    pass

try:
    from uuid import uuid7
except ImportError:
    pass

try:
    import readline

    readline.parse_and_bind("tab: complete")
except ImportError:
    pass

try:
    from rich import pretty

    pretty.install()
except ImportError:
    pass

try:
    from pydantic import BaseModel
except ImportError:
    pass

TEMP_DIR = Path(tempfile.gettempdir()) / "python-temp"
try:
    os.makedirs(TEMP_DIR)
except Exception:
    pass


# Custom Methods
def now() -> datetime:
    return datetime.now(tz=timezone.utc)


def tle_epoch(value: datetime | str) -> str | datetime:
    """Convert between a datetime object and TLE epoch string format.

    Args:
        value: Either a datetime object to convert to TLE epoch string,
            or a TLE epoch string to convert to datetime object

    Returns:
        str | datetime: If input is datetime, TLE epoch string in format YYDDD.DDDDDDDD.
            If input is str, timezone-aware datetime object in UTC

    Examples:
        >>> tle_epoch(datetime(2024, 1, 1, 12, 0, 0, tzinfo=UTC))
        '24001.50000000'
        >>> tle_epoch('24001.50000000')
        datetime.datetime(2024, 1, 1, 12, 0, 0, tzinfo=datetime.UTC)
    """
    if isinstance(value, datetime):
        if value.tzinfo is not None:
            value = value.astimezone(UTC)

        year_2digit = value.year % 100
        day_of_year = value.timetuple().tm_yday

        seconds_in_day = value.hour * 3600 + value.minute * 60 + value.second + value.microsecond / 1e6
        fractional_day = seconds_in_day / 86400.0

        fractional_str = f"{fractional_day:.8f}"[2:]
        return f"{year_2digit:02d}{day_of_year:03d}.{fractional_str}"
    elif isinstance(value, str):
        year_2digit = int(value[:2])
        day_of_year = int(value[2:5])
        fractional_day = float(value[5:])

        year = 2000 + year_2digit  # Assumes year >= 2000

        total_seconds = fractional_day * 86400.0
        hours = int(total_seconds // 3600)
        minutes = int((total_seconds % 3600) // 60)
        seconds = int(total_seconds % 60)
        microseconds = int((total_seconds % 1) * 1e6)

        # Create datetime for Jan 1 of that year, then add days
        base_date = datetime(year, 1, 1, hours, minutes, seconds, microseconds, tzinfo=UTC)
        return base_date + timedelta(days=day_of_year - 1)

    else:
        raise TypeError(f"Expected datetime or str, got {type(value).__name__}")


def tle_checksum(value: str) -> int | tuple[int, int]:
    """Calculate the checksum for TLE line(s).

    Args:
        value: A single line string from a TLE, or multiple lines separated
            by newlines. If two lines (one line break), both checksums are
            calculated. If three lines (two line breaks), the first line
            (name line) is skipped and checksums for lines 2 and 3 are returned.

    Returns:
        int | tuple[int, int]: Single checksum value (0-9) for one line,
            or tuple of two checksums for two/three line input.

    Examples:
        >>> line1 = "1 25544U 98067A   26055.47628608  .00010887  00000-0  21063-3 0  9998"
        >>> tle_checksum(line1)
        8
        >>> two_lines = '''1 25544U 98067A   26055.47628608  .00010887  00000-0  21063-3 0  9998
        ... 2 25544  51.6318 137.6731 0008377 128.8407 231.3330 15.48263422554285'''
        >>> tle_checksum(two_lines)
        (8, 5)
        >>> three_lines = '''ISS (ZARYA)
        ... 1 25544U 98067A   26055.47628608  .00010887  00000-0  21063-3 0  9998
        ... 2 25544  51.6318 137.6731 0008377 128.8407 231.3330 15.48263422554285'''
        >>> tle_checksum(three_lines)
        (8, 5)
    """
    lines = value.split("\n")

    def _calculate_line_checksum(line: str) -> int:
        """Calculate checksum for a single line."""
        line_to_check = line[:-1] if len(line) >= 69 else line

        checksum = 0
        for char in line_to_check:
            if char.isdigit():
                checksum += int(char)
            elif char == "-":
                checksum += 1

        return checksum % 10

    if len(lines) == 1:
        return _calculate_line_checksum(lines[0])
    elif 2 <= len(lines) <= 3:
        return (_calculate_line_checksum(lines[-2]), _calculate_line_checksum(lines[-1]))
    else:
        raise ValueError(f"Expected 1-3 lines, got {len(lines)}")


# REPR overrides / display hook tricks
exit = type("", (object,), {"__repr__": lambda self: __import__("sys").exit(0)})()
clear = type("", (object,), {"__repr__": lambda self: __import__("subprocess").run("clear", shell=True) or ""})()
