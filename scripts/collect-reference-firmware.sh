#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

SDK_IMAGES="$(resolve_path "${SDK_IMAGE_DIR}")"
REFERENCE="$(resolve_path "${REFERENCE_DIR}")"

require_directory "${SDK_IMAGES}"

required_files=(
    boot.img
    env.img
    idblock.img
    uboot.img
)

optional_files=(
    .env.txt
    sd_update.txt
    tftp_update.txt
)

rm -rf "${REFERENCE}"
mkdir -p "${REFERENCE}"

for file in "${required_files[@]}"; do
    require_file "${SDK_IMAGES}/${file}"
    cp -f "${SDK_IMAGES}/${file}" "${REFERENCE}/${file}"
done

for file in "${optional_files[@]}"; do
    if [[ -f "${SDK_IMAGES}/${file}" ]]; then
        cp -f "${SDK_IMAGES}/${file}" "${REFERENCE}/${file}"
    fi
done

echo "Buildroot-Referenzdateien:"
find "${REFERENCE}" \
    -maxdepth 1 -type f \
    -printf '%f\t%k KB\n' \
    | sort
