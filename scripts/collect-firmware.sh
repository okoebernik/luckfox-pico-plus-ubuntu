#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

SDK_IMAGES="$(resolve_path "${SDK_IMAGE_DIR}")"
OUTPUT="$(resolve_path "${OUTPUT_DIR}")"
FIRMWARE_OUTPUT="$(resolve_path "${FIRMWARE_OUTPUT_DIR}")"
ROOTFS_IMAGE="${OUTPUT}/${ROOTFS_IMAGE_NAME}"

require_directory "${SDK_IMAGES}"
require_file "${ROOTFS_IMAGE}"

mkdir -p "${FIRMWARE_OUTPUT}"
rm -f "${FIRMWARE_OUTPUT}"/*

required_images=(
    boot.img
    download.bin
    idblock.img
    uboot.img
    userdata.img
)

for image in "${required_images[@]}"; do
    require_file "${SDK_IMAGES}/${image}"
    cp -f "${SDK_IMAGES}/${image}" "${FIRMWARE_OUTPUT}/${image}"
done

if [[ -f "${SDK_IMAGES}/.env.txt" ]]; then
    cp -f "${SDK_IMAGES}/.env.txt" \
        "${FIRMWARE_OUTPUT}/.env.txt"
fi

cp -f "${ROOTFS_IMAGE}" \
    "${FIRMWARE_OUTPUT}/rootfs.img"

echo "Firmwaredateien:"
find "${FIRMWARE_OUTPUT}" \
    -maxdepth 1 -type f \
    -printf '%f\t%k KB\n' \
    | sort

