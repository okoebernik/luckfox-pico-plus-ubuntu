#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

require_root

ROOTFS="$(resolve_path "${ROOTFS_DIR}")"
OVERLAY_DIR="${PROJECT_DIR}/rootfs-overlay"
VERSION_FILE="${PROJECT_DIR}/VERSION"
FSTAB="${ROOTFS}/etc/fstab"
SWAPFILE="${ROOTFS}/swapfile"

require_directory "${ROOTFS}"
require_directory "${OVERLAY_DIR}"
require_file "${VERSION_FILE}"

echo "Optimiere Ubuntu-RootFS für wenig RAM ..."

# ---------------------------------------------------------------------------
# Hintergrunddienste und Timer deaktivieren
# ---------------------------------------------------------------------------

rm -f \
    "${ROOTFS}/etc/systemd/system/timers.target.wants/apt-daily.timer" \
    "${ROOTFS}/etc/systemd/system/timers.target.wants/apt-daily-upgrade.timer" \
    "${ROOTFS}/etc/systemd/system/timers.target.wants/dpkg-db-backup.timer" \
    "${ROOTFS}/etc/systemd/system/timers.target.wants/e2scrub_all.timer" \
    "${ROOTFS}/etc/systemd/system/timers.target.wants/fstrim.timer" \
    "${ROOTFS}/etc/systemd/system/timers.target.wants/motd-news.timer"

rm -f \
    "${ROOTFS}/etc/systemd/system/multi-user.target.wants/e2scrub_reap.service"

# ---------------------------------------------------------------------------
# Journald auf flüchtige, kleine Logs begrenzen
# ---------------------------------------------------------------------------

mkdir -p "${ROOTFS}/etc/systemd/journald.conf.d"

cat > "${ROOTFS}/etc/systemd/journald.conf.d/10-luckfox.conf" <<'JOURNAL'
[Journal]
Storage=volatile
RuntimeMaxUse=4M
RuntimeKeepFree=2M
Compress=no
JOURNAL

# ---------------------------------------------------------------------------
# Virtuellen Speicher für das sehr kleine RAM-Limit abstimmen
# ---------------------------------------------------------------------------

mkdir -p "${ROOTFS}/etc/sysctl.d"

cat > "${ROOTFS}/etc/sysctl.d/99-luckfox-memory.conf" <<'SYSCTL'
vm.swappiness=100
vm.vfs_cache_pressure=200
SYSCTL

# ---------------------------------------------------------------------------
# Reproduzierbares Swapfile erzeugen
# ---------------------------------------------------------------------------

echo "Richte ${SWAP_SIZE_MB} MiB Swapfile ein ..."

mkdir -p "$(dirname "${FSTAB}")"
touch "${FSTAB}"

rm -f "${SWAPFILE}"

dd if=/dev/zero \
    of="${SWAPFILE}" \
    bs=1M \
    count="${SWAP_SIZE_MB}" \
    status=progress

chmod 0600 "${SWAPFILE}"
mkswap "${SWAPFILE}" >/dev/null

# Bereits vorhandene Einträge entfernen, damit der Build idempotent bleibt.
sed -i '\|^[[:space:]]*/swapfile[[:space:]]|d' "${FSTAB}"

printf '%s\n' \
    '/swapfile none swap sw,pri=100 0 0' \
    >> "${FSTAB}"

# ---------------------------------------------------------------------------
# Luckfox-Overlay und Systemwerkzeuge installieren
# ---------------------------------------------------------------------------

echo "Installiere Luckfox-Systemwerkzeuge ..."

cp -a "${OVERLAY_DIR}/." "${ROOTFS}/"

if [[ -f "${ROOTFS}/usr/local/sbin/luckfox-expand-rootfs" ]]; then
    chmod 0755 "${ROOTFS}/usr/local/sbin/luckfox-expand-rootfs"
    chown root:root "${ROOTFS}/usr/local/sbin/luckfox-expand-rootfs"
fi

if [[ -f "${ROOTFS}/etc/systemd/system/luckfox-expand-rootfs.service" ]]; then
    chmod 0644 "${ROOTFS}/etc/systemd/system/luckfox-expand-rootfs.service"
    chown root:root "${ROOTFS}/etc/systemd/system/luckfox-expand-rootfs.service"
fi

if [[ -f "${ROOTFS}/usr/local/sbin/luckfox-set-mac" ]]; then
    chmod 0755 "${ROOTFS}/usr/local/sbin/luckfox-set-mac"
    chown root:root "${ROOTFS}/usr/local/sbin/luckfox-set-mac"
fi

if [[ -f "${ROOTFS}/etc/network/if-pre-up.d/luckfox-mac" ]]; then
    chmod 0755 "${ROOTFS}/etc/network/if-pre-up.d/luckfox-mac"
    chown root:root "${ROOTFS}/etc/network/if-pre-up.d/luckfox-mac"
fi

# ---------------------------------------------------------------------------
# Projektinformationen im Zielsystem hinterlegen
# ---------------------------------------------------------------------------
PROJECT_BUILD_DATE="$(date +%F)"

PROJECT_GIT_REVISION="$(
    git -C "${PROJECT_DIR}" rev-parse --short HEAD 2>/dev/null \
        || printf 'unknown'
)"

PROJECT_VERSION="$(
    tr -d '[:space:]' < "${VERSION_FILE}"
)"

cat > "${ROOTFS}/etc/luckfox-release" <<EOF_RELEASE
PROJECT_NAME="Luckfox Pico Plus Ubuntu"
PROJECT_VERSION="${PROJECT_VERSION}"
PROJECT_BOARD="${BOARD_NAME}"
PROJECT_UBUNTU="${UBUNTU_RELEASE}"
PROJECT_BUILD_DATE="${PROJECT_BUILD_DATE}"
PROJECT_GIT_REVISION="${PROJECT_GIT_REVISION}"
EOF_RELEASE

chmod 0644 "${ROOTFS}/etc/luckfox-release"

# Ein vorhandenes nologin-Flag darf nicht in das Image übernommen werden.
rm -f "${ROOTFS}/etc/nologin"

# ---------------------------------------------------------------------------
# Abschlusskontrollen
# ---------------------------------------------------------------------------

require_file "${SWAPFILE}"
require_file "${ROOTFS}/etc/luckfox-release"

if ! grep -qE '^[[:space:]]*/swapfile[[:space:]]+none[[:space:]]+swap[[:space:]]' "${FSTAB}"; then
    echo "Swap-Eintrag fehlt in ${FSTAB}." >&2
    exit 1
fi

echo
echo "RootFS-Optimierung abgeschlossen."
echo "Swapfile: ${SWAP_SIZE_MB} MiB"
echo "Release:  ${PROJECT_VERSION}"
