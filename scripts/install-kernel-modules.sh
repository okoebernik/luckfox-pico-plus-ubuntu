#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

require_root

ROOTFS="$(resolve_path "${ROOTFS_DIR}")"
SDK="$(resolve_path "${SDK_DIR}")"
KERNEL_OUT="$(resolve_path "${KERNEL_OUT_DIR}")"
MODULE_SOURCE="$(resolve_path "${KERNEL_MODULE_SOURCE}")"

require_directory "${ROOTFS}"
require_directory "${SDK}"
require_directory "${KERNEL_OUT}"
require_directory "${MODULE_SOURCE}"

TOOLCHAIN_PREFIX="arm-rockchip830-linux-uclibcgnueabihf-"

KVER="$(
    make -s \
        -C "${SDK}/sysdrv/source/kernel" \
        O="${KERNEL_OUT}" \
        ARCH=arm \
        CROSS_COMPILE="${TOOLCHAIN_PREFIX}" \
        kernelrelease
)"

if [[ -z "${KVER}" ]]; then
    echo "Kernelversion konnte nicht ermittelt werden." >&2
    exit 1
fi

MODULE_DEST="${ROOTFS}/lib/modules/${KVER}"

echo "Kernelversion: ${KVER}"
echo "Ziel: ${MODULE_DEST}"

mkdir -p "${MODULE_DEST}/extra"

rsync -a --delete \
    "${MODULE_SOURCE}/" \
    "${MODULE_DEST}/extra/"

for metadata_file in \
    modules.order \
    modules.builtin \
    modules.builtin.modinfo
do
    if [[ -f "${KERNEL_OUT}/${metadata_file}" ]]; then
        cp -f \
            "${KERNEL_OUT}/${metadata_file}" \
            "${MODULE_DEST}/${metadata_file}"
    fi
done

if [[ ! -x "${ROOTFS}/usr/bin/qemu-arm-static" ]]; then
    cp /usr/bin/qemu-arm-static \
        "${ROOTFS}/usr/bin/qemu-arm-static"
fi

chroot "${ROOTFS}" \
    /usr/bin/qemu-arm-static \
    /sbin/depmod -a "${KVER}"

MODULE_COUNT="$(
    find "${MODULE_DEST}/extra" \
        -type f -name '*.ko' \
        | wc -l
)"

echo "Installierte Module: ${MODULE_COUNT}"
echo "Kernelmodule wurden erfolgreich integriert."
