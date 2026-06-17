"""Merge per-unit partial JSON files into combined result files.

Run this after all per-unit cluster jobs have completed. Groups partial files in
fits/ by their prefix, merges each group, and writes one combined JSON per
group.

Usage:
    python scripts/merge_partials.py [--fits-dir fits] [--dry-run]
"""

import argparse
import json
import re
from pathlib import Path


def find_project_root() -> Path:
    path = Path.cwd().resolve()
    while path != path.parent:
        if (path / ".git").is_dir():
            return path
        path = path.parent
    return Path.cwd().resolve()


def discover_groups(fits_dir: Path) -> dict[str, list[Path]]:
    partials = sorted(fits_dir.glob("*.json"))
    groups: dict[str, list[Path]] = {}
    for p in partials:
        match = re.search(r"_(?:unit|sub)\d+(?:_\d+)*\.json$", p.name)
        if not match:
            continue
        prefix = p.name[: match.start()]
        groups.setdefault(prefix, []).append(p)
    for paths in groups.values():
        paths.sort(
            key=lambda p: [int(s) for s in re.findall(r"(?:unit|sub)(\d+)", p.name)]
            or [0]
        )
    return groups


def merge_group(paths: list[Path]) -> dict:
    partials = []
    for p in paths:
        with p.open() as f:
            partials.append(json.load(f))

    merged: dict = {}
    for key, value in partials[0].items():
        if isinstance(value, list):
            merged[key] = []
        elif isinstance(value, dict):
            merged[key] = {k: [] if isinstance(v, list) else v for k, v in value.items()}
        elif key == "fit_time":
            merged[key] = 0
        else:
            merged[key] = value

    for partial in partials:
        for key, value in partial.items():
            if isinstance(merged.get(key), list):
                merged[key] += value
            elif isinstance(merged.get(key), dict) and isinstance(value, dict):
                for inner_key, inner_value in value.items():
                    if isinstance(merged[key].get(inner_key), list):
                        merged[key][inner_key] += inner_value
                    else:
                        merged[key][inner_key] = inner_value
            elif key == "fit_time":
                merged[key] += value
            elif key not in merged:
                merged[key] = value

    return merged


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--fits-dir", default="fits", help="Directory containing partial JSONs"
    )
    parser.add_argument(
        "--dry-run", action="store_true", help="Print what would be merged without writing"
    )
    args = parser.parse_args()

    project_root = find_project_root()
    fits_dir = project_root / args.fits_dir

    groups = discover_groups(fits_dir)
    if not groups:
        print(f"No partial files (*_unit*.json or *_sub*.json) found in {fits_dir}")
        return

    for prefix, paths in sorted(groups.items()):
        output = fits_dir / f"{prefix}.json"
        print(f"{prefix}: {len(paths)} partials -> {output.relative_to(project_root)}")
        if args.dry_run:
            continue
        merged = merge_group(paths)
        with output.open("w") as f:
            json.dump(merged, f, indent=4)


if __name__ == "__main__":
    main()
