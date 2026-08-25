"""Helpers shared by the Sapling packaging scripts"""

import os
from pathlib import Path
import re
import subprocess
from typing import Tuple


VERSION_PATTERN = re.compile(
    r"0\.2\.(?P<date>\d+)-(?P<time>\d+)\+(?P<hash>[0-9a-f]+)(?:-b(?P<builddate>\d+))?"
)


def get_version_and_release(sl: Path) -> Tuple[str, str]:
    """Extract version and release strings from the sl executable"""

    version_str = subprocess.check_output([sl, "--version"], encoding="utf-8")
    m = VERSION_PATTERN.search(version_str)
    if not m:
        raise RuntimeError(f"Unexpected version string: {version_str}")

    git_date = m.group("date")
    git_time = m.group("time")
    git_hash = m.group("hash")
    build_date = m.group("builddate")

    if build_date:
        return ("0.2", f"{git_date}_{git_time}+{git_hash}_b{build_date}")
    else:
        return ("0.2", f"{git_date}_{git_time}+{git_hash}")


def get_default_artifact_dir() -> Path:
    return Path(os.getcwd()) / "out"
