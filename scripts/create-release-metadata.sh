#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

VERSION="$(cat "${PROJECT_DIR}/VERSION")"
FLASH="$(resolve_path "${FLASH_DIR}")"
RELEASE="$(resolve_path "${RELEASE_DIR}")"

require_directory "${FLASH}"

rm -rf "${RELEASE}"
mkdir -p "${RELEASE}"

cp -a "${FLASH}/." "${RELEASE}/"

required_files=(
    boot.img
    download.bin
    env.img
    idblock.img
    rootfs.img
    uboot.img
    userdata.img
)

for file in "${required_files[@]}"; do
    require_file "${RELEASE}/${file}"
done

(
    cd "${RELEASE}"
    sha256sum "${required_files[@]}" > SHA256SUMS
)

printf '%s\n' "${VERSION}" > "${RELEASE}/VERSION"

cat > "${RELEASE}/manifest.txt" <<EOF_MANIFEST
Project: ${PROJECT_NAME}
Version: ${VERSION}
Board: ${BOARD_NAME}
Ubuntu: ${UBUNTU_RELEASE}
Kernel: 5.10.160
Root device: ${ROOT_DEVICE}
Userdata device: ${USERDATA_DEVICE}
Swap: ${SWAP_SIZE_MB} MB
EOF_MANIFEST

echo "Release-Metadaten erzeugt:"
cat "${RELEASE}/manifest.txt"
