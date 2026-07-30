#!/usr/bin/env bash
set -uo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${PROJECT_DIR}/config/project.env"
VERSION_FILE="${PROJECT_DIR}/VERSION"

MIN_FREE_SPACE_GB=15

ERRORS=0
WARNINGS=0

# Terminal formatting
if [[ -t 1 ]]; then
    RED="\033[0;31m"
    GREEN="\033[0;32m"
    YELLOW="\033[0;33m"
    BLUE="\033[0;34m"
    BOLD="\033[1m"
    RESET="\033[0m"
else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    RESET=""
fi

ok() {
    printf "${GREEN}[ OK ]${RESET} %s\n" "$1"
}

warn() {
    printf "${YELLOW}[WARN]${RESET} %s\n" "$1"
    WARNINGS=$((WARNINGS + 1))
}

fail() {
    printf "${RED}[FAIL]${RESET} %s\n" "$1"
    ERRORS=$((ERRORS + 1))
}

section() {
    printf "\n${BLUE}${BOLD}%s${RESET}\n" "$1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

resolve_path() {
    local path="$1"

    if [[ "${path}" = /* ]]; then
        printf '%s\n' "${path}"
    else
        printf '%s\n' "${PROJECT_DIR}/${path}"
    fi
}

check_command() {
    local command_name="$1"

    if command_exists "${command_name}"; then
        ok "Command available: ${command_name}"
    else
        fail "Required command missing: ${command_name}"
    fi
}

check_directory() {
    local directory="$1"
    local description="$2"

    if [[ -d "${directory}" ]]; then
        ok "${description}: ${directory}"
    else
        fail "${description} not found: ${directory}"
    fi
}

check_file() {
    local file="$1"
    local description="$2"

    if [[ -f "${file}" ]]; then
        ok "${description}: ${file}"
    else
        fail "${description} not found: ${file}"
    fi
}

echo
printf "${BOLD}Luckfox Pico Plus Ubuntu Build Environment Check${RESET}\n"
printf "Project directory: %s\n" "${PROJECT_DIR}"

section "Host system"

if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release

    ok "Operating system: ${PRETTY_NAME:-unknown}"

    if [[ "${ID:-}" != "ubuntu" ]]; then
        warn "The documented build host is Ubuntu 22.04"
    elif [[ "${VERSION_ID:-}" != "22.04" ]]; then
        warn "Ubuntu ${VERSION_ID:-unknown} detected; Ubuntu 22.04 is recommended"
    fi
else
    fail "/etc/os-release could not be read"
fi

if grep -qi microsoft /proc/version 2>/dev/null; then
    ok "WSL environment detected"
fi

section "Required commands"

REQUIRED_COMMANDS=(
    bash
    git
    sudo
    rsync
    tar
    gzip
    dd
    truncate
    make
    mkswap
    mkfs.ext4
    e2fsck
    resize2fs
    mountpoint
    sha256sum
)

for command_name in "${REQUIRED_COMMANDS[@]}"; do
    check_command "${command_name}"
done

section "Project files"

if [[ -r "${CONFIG_FILE}" ]]; then
    # shellcheck disable=SC1090
    source "${CONFIG_FILE}"
    ok "Project configuration: ${CONFIG_FILE}"
else
    fail "Project configuration not found: ${CONFIG_FILE}"
fi

if [[ -f "${VERSION_FILE}" ]]; then
    PROJECT_VERSION="$(tr -d '[:space:]' < "${VERSION_FILE}")"

    if [[ -n "${PROJECT_VERSION}" ]]; then
        ok "Project version: ${PROJECT_VERSION}"
    else
        fail "VERSION file is empty"
    fi
else
    fail "VERSION file not found: ${VERSION_FILE}"
fi

SDK_PATH="$(resolve_path "${SDK_DIR:-sdk}")"
ROOTFS_PATH="$(resolve_path "${ROOTFS_DIR:-rootfs/ubuntu-jammy}")"
SDK_IMAGE_PATH="$(resolve_path "${SDK_IMAGE_DIR:-sdk/output/image}")"
KERNEL_OUT_PATH="$(resolve_path "${KERNEL_OUT_DIR:-sdk/sysdrv/source/objs_kernel}")"
KERNEL_MODULE_PATH="$(resolve_path "${KERNEL_MODULE_SOURCE:-sdk/sysdrv/out/kernel_drv_ko}")"
OUTPUT_PATH="$(resolve_path "${OUTPUT_DIR:-output}")"

check_directory "${SDK_PATH}" "SDK directory"
check_directory "${ROOTFS_PATH}" "Ubuntu RootFS directory"
check_directory "${SDK_IMAGE_PATH}" "SDK firmware image directory"
check_directory "${KERNEL_OUT_PATH}" "Kernel build output"
check_directory "${KERNEL_MODULE_PATH}" "Kernel module output"

for firmware_file in boot.img download.bin idblock.img uboot.img userdata.img; do
    check_file \
        "${SDK_IMAGE_PATH}/${firmware_file}" \
        "SDK firmware image ${firmware_file}"
done

if [[ -x "${PROJECT_DIR}/scripts/build-all.sh" ]]; then
    ok "Main build script is executable"
else
    fail "scripts/build-all.sh is missing or not executable"
fi

section "Filesystem and permissions"

mkdir -p "${OUTPUT_PATH}" 2>/dev/null || true

if [[ -w "${PROJECT_DIR}" ]]; then
    ok "Project directory is writable"
else
    fail "Project directory is not writable"
fi

if [[ -w "${OUTPUT_PATH}" ]]; then
    ok "Output directory is writable"
else
    fail "Output directory is not writable"
fi

AVAILABLE_KB="$(df -Pk "${PROJECT_DIR}" | awk 'NR == 2 {print $4}')"

if [[ "${AVAILABLE_KB}" =~ ^[0-9]+$ ]]; then
    AVAILABLE_GB=$((AVAILABLE_KB / 1024 / 1024))

    if (( AVAILABLE_GB >= MIN_FREE_SPACE_GB )); then
        ok "Free disk space: ${AVAILABLE_GB} GiB"
    else
        fail "Only ${AVAILABLE_GB} GiB free; at least ${MIN_FREE_SPACE_GB} GiB required"
    fi
else
    warn "Free disk space could not be determined"
fi

section "Privilege check"

if sudo -n true 2>/dev/null; then
    ok "sudo credentials are already available"
else
    warn "sudo authentication will be required during the build"
fi

section "Result"

if (( ERRORS > 0 )); then
    printf "\n${RED}${BOLD}Environment check failed.${RESET}\n"
    printf "Errors:   %d\n" "${ERRORS}"
    printf "Warnings: %d\n" "${WARNINGS}"
    printf "\nResolve all errors before starting the build.\n"
    exit 1
fi

printf "\n${GREEN}${BOLD}Environment check successful.${RESET}\n"
printf "Errors:   %d\n" "${ERRORS}"
printf "Warnings: %d\n" "${WARNINGS}"

exit 0
