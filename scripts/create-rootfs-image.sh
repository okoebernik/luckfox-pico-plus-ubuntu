#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

require_root

ROOTFS="$(resolve_path "${ROOTFS_DIR}")"
OUTPUT="$(resolve_path "${OUTPUT_DIR}")"
IMAGE="${OUTPUT}/${ROOTFS_IMAGE_NAME}"

require_directory "${ROOTFS}"

mkdir -p "${OUTPUT}"

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

echo "Prüfe Dateisystem ..."
e2fsck -f -y "${IMAGE}"

echo "Verkleinere auf minimale Dateisystemgröße ..."
resize2fs -M "${IMAGE}"

e2fsck -f -y "${IMAGE}"

echo
ls -lh "${IMAGE}"
echo "RootFS-Image wurde erfolgreich erzeugt."
