#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OVERLAY_DIR="${PROJECT_DIR}/rootfs-overlay"
INSTALLER_SOURCE="${OVERLAY_DIR}/usr/local/sbin/luckfox-install-overlay"

REMOTE_USER="pico"
REMOTE_HOST=""
REMOTE_PORT="22"
DRY_RUN=0

usage() {
    cat <<'EOF'
Usage:
  ./scripts/deploy-overlay.sh [options] <host>

Options:
  -u, --user USER       SSH user (default: pico)
  -p, --port PORT       SSH port (default: 22)
  -n, --dry-run         Show files without changing the target
  -h, --help            Show this help
EOF
}

log() { printf 'deploy-overlay: %s\n' "$*"; }
fail() { printf 'deploy-overlay: ERROR: %s\n' "$*" >&2; exit 1; }

while (($# > 0)); do
    case "$1" in
        -u|--user) [[ $# -ge 2 ]] || fail "Missing value for $1"; REMOTE_USER="$2"; shift 2 ;;
        -p|--port) [[ $# -ge 2 ]] || fail "Missing value for $1"; REMOTE_PORT="$2"; shift 2 ;;
        -n|--dry-run) DRY_RUN=1; shift ;;
        -h|--help) usage; exit 0 ;;
        -*) fail "Unknown option: $1" ;;
        *) [[ -z "${REMOTE_HOST}" ]] || fail "Only one target host may be specified"; REMOTE_HOST="$1"; shift ;;
    esac
done

[[ -n "${REMOTE_HOST}" ]] || { usage; exit 1; }
[[ -d "${OVERLAY_DIR}" ]] || fail "Overlay directory not found: ${OVERLAY_DIR}"
[[ -f "${INSTALLER_SOURCE}" ]] || fail "Installer not found: ${INSTALLER_SOURCE}"
[[ "${REMOTE_PORT}" =~ ^[0-9]+$ ]] || fail "Invalid SSH port: ${REMOTE_PORT}"

command -v ssh >/dev/null 2>&1 || fail "ssh is not installed"
command -v scp >/dev/null 2>&1 || fail "scp is not installed"
command -v tar >/dev/null 2>&1 || fail "tar is not installed"

SSH_TARGET="${REMOTE_USER}@${REMOTE_HOST}"
REMOTE_TMP="/tmp/luckfox-overlay-deploy"
REMOTE_INSTALLER_TMP="/tmp/luckfox-install-overlay"

SSH_OPTIONS=(
    -p "${REMOTE_PORT}"
    -o ConnectTimeout=30
    -o ConnectionAttempts=3
    -o ServerAliveInterval=15
    -o ServerAliveCountMax=4
)

SCP_OPTIONS=(
    -P "${REMOTE_PORT}"
    -o ConnectTimeout=30
    -o ConnectionAttempts=3
    -o ServerAliveInterval=15
    -o ServerAliveCountMax=4
)

log "Target: ${SSH_TARGET}"
log "Overlay: ${OVERLAY_DIR}"
log "Mode: $([[ ${DRY_RUN} -eq 1 ]] && printf 'dry-run' || printf 'deploy')"
log "Testing SSH connection..."

ssh "${SSH_OPTIONS[@]}" "${SSH_TARGET}" true || fail "Could not connect to ${SSH_TARGET}"

if ((DRY_RUN)); then
    log "Files that would be deployed:"
    (cd "${OVERLAY_DIR}" && find . \( -type f -o -type l \) -print | sort)
    log "Dry-run completed. No target files were changed."
    exit 0
fi

log "Preparing temporary directory on target..."
ssh "${SSH_OPTIONS[@]}" "${SSH_TARGET}" "rm -rf '${REMOTE_TMP}' && mkdir -p '${REMOTE_TMP}'"

log "Transferring overlay with tar over SSH..."
tar --create --file=- --directory="${OVERLAY_DIR}" . |
ssh "${SSH_OPTIONS[@]}" "${SSH_TARGET}"     "tar --extract --file=- --touch --warning=no-timestamp --directory='${REMOTE_TMP}'"

log "Uploading installer bootstrap..."
scp "${SCP_OPTIONS[@]}" "${INSTALLER_SOURCE}" "${SSH_TARGET}:${REMOTE_INSTALLER_TMP}"

log "Installing overlay..."
ssh -t "${SSH_OPTIONS[@]}" "${SSH_TARGET}"     "sudo install -o root -g root -m 0755 '${REMOTE_INSTALLER_TMP}' /usr/local/sbin/luckfox-install-overlay      && sudo /usr/local/sbin/luckfox-install-overlay '${REMOTE_TMP}'"

log "Cleaning temporary files..."
ssh "${SSH_OPTIONS[@]}" "${SSH_TARGET}" "rm -rf '${REMOTE_TMP}' '${REMOTE_INSTALLER_TMP}'"

log "Deployment completed successfully."
