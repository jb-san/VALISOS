#!/usr/bin/env bash
# GPU detection script for VALISOS installer
# Outputs: nvidia, amd, intel, or none

set -euo pipefail

detect_gpu() {
    local lspci_output
    lspci_output=$(lspci 2>/dev/null || true)

    if echo "$lspci_output" | grep -iq 'nvidia'; then
        echo "nvidia"
    elif echo "$lspci_output" | grep -iqE 'amd|ati|radeon'; then
        echo "amd"
    elif echo "$lspci_output" | grep -iq 'intel.*graphics\|intel.*uhd\|intel.*iris'; then
        echo "intel"
    else
        echo "none"
    fi
}

# If sourced, just define the function. If executed, run it.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    detect_gpu
fi
