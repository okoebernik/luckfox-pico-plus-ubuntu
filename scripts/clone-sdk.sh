#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SDK_DIR="${PROJECT_DIR}/sdk"
SDK_REPOSITORY="https://github.com/LuckfoxTECH/luckfox-pico.git"

if [[ -d "${SDK_DIR}/.git" ]]; then
    echo "SDK ist bereits vorhanden: ${SDK_DIR}"
    exit 0
fi

git clone --depth 1 "${SDK_REPOSITORY}" "${SDK_DIR}"

echo
echo "SDK wurde nach ${SDK_DIR} heruntergeladen."
