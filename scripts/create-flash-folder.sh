#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

REFERENCE="$(resolve_path "${REFERENCE_DIR}")"
FIRMWARE="$(resolve_path "${FIRMWARE_OUTPUT_DIR}")"
FLASH="$(resolve_path "${FLASH_DIR}")"

require_directory "${REFERENCE}"
require_directory "${FIRMWARE}"

rm -rf "${FLASH}"
mkdir -p "${FLASH}"

reference_files=(
    env.img
    idblock.img
    uboot.img
    boot.img
    sd_update.txt
    tftp_update.txt
    .env.txt
)

for file in "${reference_files[@]}"; do
    if [[ -f "${REFERENCE}/${file}" ]]; then
        cp -f "${REFERENCE}/${file}" "${FLASH}/${file}"
    fi
done

firmware_files=(
    download.bin
    rootfs.img
    userdata.img
)

for file in "${firmware_files[@]}"; do
    require_file "${FIRMWARE}/${file}"
    cp -f "${FIRMWARE}/${file}" "${FLASH}/${file}"
done

echo "Flash-Ordner erstellt:"
ls -lah "${FLASH}"
