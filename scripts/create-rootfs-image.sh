#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

require_root

ROOTFS="$(resolve_path "${ROOTFS_DIR}")"
OUTPUT="$(resolve_path "${OUTPUT_DIR}")"
IMAGE="${OUTPUT}/${ROOTFS_IMAGE_NAME}"
MOUNT_DIR="${OUTPUT}/rootfs-image-mount"

require_directory "${ROOTFS}"

mkdir -p "${OUTPUT}"
mkdir -p "${MOUNT_DIR}"

cleanup() {
    if mountpoint -q "${MOUNT_DIR}"; then
        umount "${MOUNT_DIR}"
    fi
}

trap cleanup EXIT

if mountpoint -q "${ROOTFS}/proc"; then
    echo "${ROOTFS}/proc ist noch eingehängt." >&2
    exit 1
fi

if mountpoint -q "${ROOTFS}/sys"; then
    echo "${ROOTFS}/sys ist noch eingehängt." >&2
    exit 1
fi

if mountpoint -q "${ROOTFS}/dev"; then
    echo "${ROOTFS}/dev ist noch eingehängt." >&2
    exit 1
fi

if mountpoint -q "${MOUNT_DIR}"; then
    umount "${MOUNT_DIR}"
fi

rm -f "${IMAGE}"

echo "Erzeuge leeres Image: ${IMAGE}"
truncate -s "${ROOTFS_IMAGE_SIZE}" "${IMAGE}"

echo "Formatiere ext4 und kopiere RootFS ..."
mkfs.ext4 \
    -F \
    -L rootfs \
    -m 0 \
    -d "${ROOTFS}" \
    "${IMAGE}"

echo "Mounte RootFS-Image ..."
mount -o loop "${IMAGE}" "${MOUNT_DIR}"

echo "Erzeuge ${SWAP_SIZE_MB} MiB Swapfile direkt im ext4-Image ..."

rm -f "${MOUNT_DIR}/swapfile"

dd if=/dev/zero \
    of="${MOUNT_DIR}/swapfile" \
    bs=1M \
    count="${SWAP_SIZE_MB}" \
    status=progress

chmod 0600 "${MOUNT_DIR}/swapfile"
mkswap "${MOUNT_DIR}/swapfile"

sync
umount "${MOUNT_DIR}"

echo "Prüfe Dateisystem ..."
e2fsck -f -y "${IMAGE}"

echo "Verkleinere auf minimale Dateisystemgröße ..."
resize2fs -M "${IMAGE}"

e2fsck -f -y "${IMAGE}"

echo
ls -lh "${IMAGE}"
echo "RootFS-Image wurde erfolgreich erzeugt."