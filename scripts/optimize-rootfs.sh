#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

require_root

ROOTFS="$(resolve_path "${ROOTFS_DIR}")"
require_directory "${ROOTFS}"

echo "Optimiere Ubuntu-RootFS für wenig RAM ..."

rm -f \
  "${ROOTFS}/etc/systemd/system/timers.target.wants/apt-daily.timer" \
  "${ROOTFS}/etc/systemd/system/timers.target.wants/apt-daily-upgrade.timer" \
  "${ROOTFS}/etc/systemd/system/timers.target.wants/dpkg-db-backup.timer" \
  "${ROOTFS}/etc/systemd/system/timers.target.wants/e2scrub_all.timer" \
  "${ROOTFS}/etc/systemd/system/timers.target.wants/fstrim.timer" \
  "${ROOTFS}/etc/systemd/system/timers.target.wants/motd-news.timer"

rm -f \
  "${ROOTFS}/etc/systemd/system/multi-user.target.wants/e2scrub_reap.service"

mkdir -p "${ROOTFS}/etc/systemd/journald.conf.d"

cat > "${ROOTFS}/etc/systemd/journald.conf.d/10-luckfox.conf" <<'JOURNAL'
[Journal]
Storage=volatile
RuntimeMaxUse=4M
RuntimeKeepFree=2M
Compress=no
JOURNAL

mkdir -p "${ROOTFS}/etc/sysctl.d"

cat > "${ROOTFS}/etc/sysctl.d/99-luckfox-memory.conf" <<'SYSCTL'
vm.swappiness=100
vm.vfs_cache_pressure=200
SYSCTL

rm -f "${ROOTFS}/etc/nologin"

echo "Installiere automatische RootFS-Erweiterung ..."

OVERLAY_DIR="${PROJECT_DIR}/rootfs-overlay"

require_directory "${OVERLAY_DIR}"

cp -a "${OVERLAY_DIR}/." "${ROOTFS}/"

chmod 0755 \
    "${ROOTFS}/usr/local/sbin/luckfox-expand-rootfs"

mkdir -p \
    "${ROOTFS}/etc/systemd/system/multi-user.target.wants"

ln -sfn \
    ../luckfox-expand-rootfs.service \
    "${ROOTFS}/etc/systemd/system/multi-user.target.wants/luckfox-expand-rootfs.service"

echo "RootFS-Optimierung abgeschlossen."
