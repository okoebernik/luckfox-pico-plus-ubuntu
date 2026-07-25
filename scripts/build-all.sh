#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${PROJECT_DIR}"

echo "=== 1/6 RootFS optimieren ==="
sudo ./scripts/optimize-rootfs.sh

echo
echo "=== 2/6 Kernelmodule integrieren ==="
sudo ./scripts/install-kernel-modules.sh

echo
echo "=== 3/6 RootFS-Image erzeugen ==="
sudo ./scripts/create-rootfs-image.sh

echo
echo "=== 4/6 Firmwaredateien sammeln ==="
./scripts/collect-firmware.sh

echo
echo "=== 5/6 Flash-Ordner erzeugen ==="
./scripts/create-flash-folder.sh

echo
echo "=== 6/6 Release-Metadaten erzeugen ==="
./scripts/create-release-metadata.sh

echo
echo "Release fertig:"
ls -lah output/release
