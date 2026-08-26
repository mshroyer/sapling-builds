#!/usr/bin/python3

"""Make a Sapling DEB

Given a built Sapling binary and isl-dist.tar.xz, produces a
properly-versioned DEB that installs them.  This is the Debian/Ubuntu
counterpart to make_rpm.py.

"""

import argparse
import os
import platform
from pathlib import Path
import re
import shutil
import subprocess

from pkgcommon import get_default_artifact_dir, get_version_and_release


DEBBUILD = Path(os.environ["HOME"]) / "debbuild"


def get_depends(sl: Path) -> str:
    """Compute the package's Depends line.

    rpmbuild generates dependencies on the binary's linked libraries
    automatically; dpkg-deb does not, so resolve each library sl links
    against to the package that owns it.  git and nodejs mirror the manual
    Requires in sapling.spec.
    """

    needed = set(
        re.findall(
            r"\(NEEDED\)\s+Shared library: \[(.+?)\]",
            subprocess.check_output(["readelf", "-d", sl], encoding="utf-8"),
        )
    )

    deps = {"git", "nodejs"}
    for line in subprocess.check_output(["ldd", sl], encoding="utf-8").splitlines():
        # ldd resolves the full transitive closure, but like rpmbuild we only
        # want dependencies for the libraries sl itself links against.
        m = re.match(r"\s*(\S+) => (/\S+)", line)
        if not m or m.group(1) not in needed:
            continue
        for path in (m.group(2), os.path.realpath(m.group(2))):
            query = subprocess.run(
                ["dpkg", "-S", path], capture_output=True, encoding="utf-8"
            )
            if query.returncode == 0:
                deps.add(query.stdout.split(":", 1)[0])
                break
    return ", ".join(sorted(deps))


def build_deb(artifact_dir: Path) -> Path:
    sl = artifact_dir / "sl"
    isl_dist = artifact_dir / "isl-dist.tar.xz"

    ver, rel = get_version_and_release(sl)
    dist_tag = os.environ.get("DISTRO_TAG", "ub2604")

    # A Debian version can't contain underscores, so translate the RPM
    # release string's field separators into dots for the control file.  The
    # output filename keeps the same shape as the RPMs'.
    deb_version = f"{ver}.{rel.replace('_', '.')}"

    pkgdir = DEBBUILD / "sapling"
    if pkgdir.exists():
        shutil.rmtree(pkgdir)

    bindir = pkgdir / "usr" / "bin"
    libdir = pkgdir / "usr" / "lib" / "sapling"
    bindir.mkdir(parents=True)
    libdir.mkdir(parents=True)

    shutil.copy(sl, bindir / "sl")
    subprocess.run(["strip", bindir / "sl"], check=True)
    os.chmod(bindir / "sl", 0o755)
    shutil.copy(isl_dist, libdir / "isl-dist.tar.xz")
    os.chmod(libdir / "isl-dist.tar.xz", 0o644)

    debian = pkgdir / "DEBIAN"
    debian.mkdir()
    (debian / "control").write_text(
        "\n".join(
            [
                "Package: sapling",
                f"Version: {deb_version}",
                "Section: devel",
                "Priority: optional",
                f"Architecture: {get_deb_architecture()}",
                "Maintainer: Mark Shroyer <mark@shroyer.name>",
                "Homepage: https://github.com/mshroyer/sapling-builds",
                f"Depends: {get_depends(bindir / 'sl')}",
                "Description: Sapling SCM",
                " Unofficial build of the Sapling source control manager.",
                "",
            ]
        )
    )

    deb = DEBBUILD / f"sapling-{ver}-{rel}.{dist_tag}.{platform.machine()}.deb"
    subprocess.run(
        ["dpkg-deb", "--build", "--root-owner-group", pkgdir, deb],
        check=True,
    )
    return deb


def get_deb_architecture() -> str:
    """The Debian name for this machine's architecture, e.g. amd64"""

    return subprocess.check_output(
        ["dpkg", "--print-architecture"], encoding="utf-8"
    ).strip()


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
    parser.add_argument("--out", type=Path, help="Optional output directory")
    args = parser.parse_args()

    deb = build_deb(args.artifact_dir)

    if args.out:
        print(f"Copying output to {args.out}")
        args.out.mkdir(parents=True, exist_ok=True)
        shutil.copy(deb, args.out)


if __name__ == "__main__":
    main()
