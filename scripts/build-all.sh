#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${PROJECT_DIR}"

echo "=== 1/8 Build-Umgebung prüfen ==="
./scripts/check-build-environment.sh

echo "=== 2/8 Buildroot-Referenzdateien sichern ==="
./scripts/collect-reference-firmware.sh

echo
echo "=== 3/8 RootFS optimieren ==="
sudo ./scripts/optimize-rootfs.sh

echo
echo "=== 4/8 Kernelmodule integrieren ==="
sudo ./scripts/install-kernel-modules.sh

echo
echo "=== 5/8 RootFS-Image erzeugen ==="
sudo ./scripts/create-rootfs-image.sh

echo
echo "=== 6/8 Firmwaredateien sammeln ==="
./scripts/collect-firmware.sh

echo
echo "=== 7/8 Flash-Ordner erzeugen ==="
./scripts/create-flash-folder.sh

echo
echo "=== 8/8 Release-Metadaten erzeugen ==="
./scripts/create-release-metadata.sh

echo
echo "Release fertig:"
ls -lah output/release
