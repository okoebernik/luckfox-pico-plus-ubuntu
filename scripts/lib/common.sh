#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIG_FILE="${PROJECT_DIR}/config/project.env"

if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "Konfigurationsdatei fehlt: ${CONFIG_FILE}" >&2
    exit 1
fi

# shellcheck disable=SC1090
source "${CONFIG_FILE}"

resolve_path() {
    local path="$1"

    if [[ "${path}" = /* ]]; then
        printf '%s\n' "${path}"
    else
        printf '%s\n' "${PROJECT_DIR}/${path}"
    fi
}

require_directory() {
    local directory="$1"

    if [[ ! -d "${directory}" ]]; then
        echo "Verzeichnis fehlt: ${directory}" >&2
        exit 1
    fi
}

require_file() {
    local file="$1"

    if [[ ! -f "${file}" ]]; then
        echo "Datei fehlt: ${file}" >&2
        exit 1
    fi
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        echo "Dieses Skript muss mit sudo ausgeführt werden." >&2
        exit 1
    fi
}
