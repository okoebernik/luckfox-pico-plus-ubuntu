#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${PROJECT_DIR}"

echo "=== Shell syntax ==="
while IFS= read -r -d '' script; do
    bash -n "${script}"
    printf '[ OK ] %s\n' "${script}"
done < <(find scripts -type f -name '*.sh' -print0 | sort -z)

echo
echo "=== Executable shell scripts ==="
while IFS= read -r -d '' script; do
    if [[ ! -x "${script}" ]]; then
        printf '[FAIL] Shell script is not executable: %s\n' "${script}" >&2
        exit 1
    fi
    printf '[ OK ] %s\n' "${script}"
done < <(find scripts -type f -name '*.sh' -print0 | sort -z)

echo
echo "=== Documentation and SVG files ==="
python3 - "${PROJECT_DIR}" <<'PYTHON'
from __future__ import annotations

import re
import subprocess
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from urllib.parse import unquote


project_dir = Path(sys.argv[1])
tracked_files = subprocess.check_output(
    ["git", "ls-files", "-z", "--", "*.md", "*.svg"],
    cwd=project_dir,
).decode("utf-8").split("\0")
repository_files = [
    project_dir / relative_path
    for relative_path in tracked_files
    if relative_path
]
markdown_files = sorted(
    path for path in repository_files if path.suffix.lower() == ".md"
)
svg_files = sorted(
    path for path in repository_files if path.suffix.lower() == ".svg"
)
errors: list[str] = []

markdown_link = re.compile(r"!?\[[^\]]*]\(([^)]+)\)")
html_link = re.compile(r"""(?:href|src)=["']([^"']+)["']""")
external_prefixes = ("http://", "https://", "mailto:", "tel:", "data:")


def local_target(raw_target: str) -> str | None:
    target = raw_target.strip()
    if target.startswith("<") and target.endswith(">"):
        target = target[1:-1]
    if " " in target and not target.startswith(("./", "../")):
        target = target.split(maxsplit=1)[0]
    target = unquote(target.split("#", 1)[0].split("?", 1)[0])
    if not target or target.startswith("#") or target.startswith(external_prefixes):
        return None
    return target


for markdown_file in markdown_files:
    text = markdown_file.read_text(encoding="utf-8")
    relative_file = markdown_file.relative_to(project_dir)

    fence_marker: str | None = None
    fence_line = 0
    for line_number, line in enumerate(text.splitlines(), start=1):
        match = re.match(r"^\s*(`{3,}|~{3,})", line)
        if not match:
            continue
        marker = match.group(1)
        if fence_marker is None:
            fence_marker = marker
            fence_line = line_number
        elif marker[0] == fence_marker[0] and len(marker) >= len(fence_marker):
            fence_marker = None

    if fence_marker is not None:
        errors.append(
            f"{relative_file}:{fence_line}: unclosed Markdown code fence"
        )

    raw_targets = markdown_link.findall(text) + html_link.findall(text)
    for raw_target in raw_targets:
        target = local_target(raw_target)
        if target is None:
            continue
        resolved = (markdown_file.parent / target).resolve()
        try:
            resolved.relative_to(project_dir)
        except ValueError:
            errors.append(
                f"{relative_file}: local link leaves repository: {raw_target}"
            )
            continue
        if not resolved.exists():
            errors.append(
                f"{relative_file}: local link target does not exist: {raw_target}"
            )

    print(f"[ OK ] {relative_file}")

for svg_file in svg_files:
    relative_file = svg_file.relative_to(project_dir)
    try:
        ET.parse(svg_file)
    except ET.ParseError as error:
        errors.append(f"{relative_file}: invalid SVG XML: {error}")
    else:
        print(f"[ OK ] {relative_file}")

if errors:
    print("\nRepository validation failed:", file=sys.stderr)
    for error in errors:
        print(f"[FAIL] {error}", file=sys.stderr)
    raise SystemExit(1)

print(
    f"\nValidated {len(markdown_files)} Markdown files "
    f"and {len(svg_files)} SVG files."
)
PYTHON

echo
echo "Repository checks passed."
