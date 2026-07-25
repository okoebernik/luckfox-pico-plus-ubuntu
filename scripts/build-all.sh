#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "${PROJECT_DIR}"

echo "=== 1/3 Kernelmodule integrieren ==="
sudo ./scripts/install-kernel-modules.sh

echo
echo "=== 2/3 Ubuntu-RootFS-Image erzeugen ==="
sudo ./scripts/create-rootfs-image.sh

echo
echo "=== 3/3 Firmwaredateien sammeln ==="
./scripts/collect-firmware.sh

echo
echo "Build abgeschlossen:"
ls -lah output/firmware
