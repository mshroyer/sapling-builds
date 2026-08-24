#!/usr/bin/python3

"""Make a Sapling RPM

Given a built Sapling binary and isl-dist.tar.xz, produces a
properly-versioned RPM that installs them.

"""

import argparse
import os
import platform
from pathlib import Path
import re
import shutil
import subprocess
from typing import Tuple


VERSION_PATTERN = re.compile(
    r"0\.2\.(?P<date>\d+)-(?P<time>\d+)\+(?P<hash>[0-9a-f]+)(?:-b(?P<builddate>\d+))?"
)
RPMBUILD = Path(os.environ["HOME"]) / "rpmbuild"


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


def build_rpm(spec_file: Path, artifact_dir: Path):
    sl = artifact_dir / "sl"
    isl_dist = artifact_dir / "isl-dist.tar.xz"

    ver, rel = get_version_and_release(sl)

    subprocess.run(["rpmdev-setuptree"], check=True)

    shutil.copy(sl, RPMBUILD / "BUILD")
    shutil.copy(isl_dist, RPMBUILD / "BUILD")

    subprocess.run(
        [
            "strip",
            RPMBUILD / "BUILD" / "sl",
        ],
        check=True,
    )

    subprocess.run(
        [
            "rpmbuild",
            "-bb",
            spec_file,
            "-D",
            f"target_arch {platform.machine()}",
            "-D",
            f"ver {ver}",
            "-D",
            f"rel {rel}",
        ],
        check=True,
    )


def get_default_artifact_dir() -> Path:
    return Path(os.getcwd()) / "out"


def get_default_spec() -> Path:
    return Path(__file__).parent / "sapling.spec"


def main():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "--artifact_dir",
        type=Path,
        help="Directory containing build artifacts",
        default=get_default_artifact_dir(),
    )
    parser.add_argument(
        "--spec", type=Path, help="Path to the spec file", default=get_default_spec()
    )
    parser.add_argument("--out", type=Path, help="Optional output directory")
    args = parser.parse_args()

    build_rpm(args.spec, args.artifact_dir)

    if args.out:
        print(f"Copying output to {args.out}")
        shutil.copytree(
            RPMBUILD / "RPMS" / platform.machine(), args.out, dirs_exist_ok=True
        )


if __name__ == "__main__":
    main()
