#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

VERSION="$(tr -d '[:space:]' < "${PROJECT_DIR}/VERSION")"
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

# -------------------------------------------------
# Release checksums
# -------------------------------------------------

(
    cd "${RELEASE}"
    sha256sum "${required_files[@]}" > SHA256SUMS
)

printf '%s\n' "${VERSION}" > "${RELEASE}/VERSION"

# -------------------------------------------------
# Dynamic build information
# -------------------------------------------------

BUILD_DATE="$(date --iso-8601=seconds)"
BUILD_HOST="$(hostname 2>/dev/null || printf 'unknown')"
BUILD_USER="${USER:-unknown}"

GIT_COMMIT="$(
    git -C "${PROJECT_DIR}" rev-parse HEAD 2>/dev/null \
        || printf 'unknown'
)"

GIT_COMMIT_SHORT="$(
    git -C "${PROJECT_DIR}" rev-parse --short HEAD 2>/dev/null \
        || printf 'unknown'
)"

GIT_BRANCH="$(
    git -C "${PROJECT_DIR}" branch --show-current 2>/dev/null \
        || printf 'unknown'
)"

if git -C "${PROJECT_DIR}" diff --quiet --ignore-submodules HEAD 2>/dev/null; then
    GIT_STATE="clean"
else
    GIT_STATE="modified"
fi

HOST_OS="unknown"

if [[ -r /etc/os-release ]]; then
    HOST_OS="$(
        . /etc/os-release
        printf '%s' "${PRETTY_NAME:-unknown}"
    )"
fi

KERNEL_VERSION="unknown"

if [[ -d "${KERNEL_OUT_DIR}" ]]; then
    KERNEL_VERSION="$(
        find "${KERNEL_OUT_DIR}" \
            -type d \
            -path '*/lib/modules/*' \
            -printf '%f\n' \
            2>/dev/null \
            | sort -V \
            | tail -n 1
    )"
fi

if [[ -z "${KERNEL_VERSION}" || "${KERNEL_VERSION}" == "unknown" ]]; then
    KERNEL_VERSION="$(
        find "$(resolve_path "${ROOTFS_DIR}")/lib/modules" \
            -mindepth 1 \
            -maxdepth 1 \
            -type d \
            -printf '%f\n' \
            2>/dev/null \
            | sort -V \
            | tail -n 1
    )"
fi

KERNEL_VERSION="${KERNEL_VERSION:-unknown}"

ROOTFS_SIZE_BYTES="$(stat -c '%s' "${RELEASE}/rootfs.img")"
USERDATA_SIZE_BYTES="$(stat -c '%s' "${RELEASE}/userdata.img")"

ROOTFS_SIZE_HUMAN="$(du -h "${RELEASE}/rootfs.img" | awk '{print $1}')"
USERDATA_SIZE_HUMAN="$(du -h "${RELEASE}/userdata.img" | awk '{print $1}')"

RELEASE_SIZE_HUMAN="$(du -sh "${RELEASE}" | awk '{print $1}')"

# -------------------------------------------------
# Machine-readable manifest
# -------------------------------------------------

cat > "${RELEASE}/manifest.txt" <<EOF_MANIFEST
Project: ${PROJECT_NAME}
Version: ${VERSION}
Board: ${BOARD_NAME}
Ubuntu: ${UBUNTU_RELEASE}
Kernel: ${KERNEL_VERSION}
Architecture: ARMHF

Root device: ${ROOT_DEVICE}
Userdata device: ${USERDATA_DEVICE}
Swap: ${SWAP_SIZE_MB} MB

Build date: ${BUILD_DATE}
Build host: ${BUILD_HOST}
Build user: ${BUILD_USER}
Host OS: ${HOST_OS}

Git branch: ${GIT_BRANCH}
Git commit: ${GIT_COMMIT}
Git state: ${GIT_STATE}

RootFS image bytes: ${ROOTFS_SIZE_BYTES}
Userdata image bytes: ${USERDATA_SIZE_BYTES}
EOF_MANIFEST

# -------------------------------------------------
# Human-readable build report
# -------------------------------------------------

cat > "${RELEASE}/build-report.md" <<EOF_REPORT
# Luckfox Pico Plus Ubuntu Build Report

## Release

| Property | Value |
|----------|-------|
| Project | ${PROJECT_NAME} |
| Version | ${VERSION} |
| Board | ${BOARD_NAME} |
| Ubuntu release | ${UBUNTU_RELEASE} |
| Architecture | ARMHF |
| Kernel | ${KERNEL_VERSION} |

## Build Environment

| Property | Value |
|----------|-------|
| Build date | ${BUILD_DATE} |
| Build host | ${BUILD_HOST} |
| Build user | ${BUILD_USER} |
| Host operating system | ${HOST_OS} |

## Git Information

| Property | Value |
|----------|-------|
| Branch | ${GIT_BRANCH} |
| Commit | \`${GIT_COMMIT_SHORT}\` |
| Full commit | \`${GIT_COMMIT}\` |
| Working tree | ${GIT_STATE} |

## Storage Layout

| Property | Value |
|----------|-------|
| Root device | ${ROOT_DEVICE} |
| Userdata device | ${USERDATA_DEVICE} |
| Swap size | ${SWAP_SIZE_MB} MB |

## Image Sizes

| Image | Size | Bytes |
|-------|------|-------|
| rootfs.img | ${ROOTFS_SIZE_HUMAN} | ${ROOTFS_SIZE_BYTES} |
| userdata.img | ${USERDATA_SIZE_HUMAN} | ${USERDATA_SIZE_BYTES} |
| Complete release directory | ${RELEASE_SIZE_HUMAN} | — |

## Release Files

| File | SHA-256 |
|------|---------|
EOF_REPORT

while read -r checksum filename; do
    printf '| `%s` | `%s` |\n' \
        "${filename}" \
        "${checksum}" \
        >> "${RELEASE}/build-report.md"
done < "${RELEASE}/SHA256SUMS"

cat >> "${RELEASE}/build-report.md" <<'EOF_REPORT'

## Verification

Verify all release images with:

```bash
sha256sum -c SHA256SUMS
