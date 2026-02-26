#!/usr/bin/env bash
# VALISOS Installer
# Interactive installer for the AI Agent-First Linux Distribution

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALISOS_REPO="https://github.com/YOUR_USER/VALISOS.git"  # TODO: update with real repo URL

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

banner() {
    echo -e "${CYAN}"
    echo "  ██╗   ██╗ █████╗ ██╗     ██╗███████╗ ██████╗ ███████╗"
    echo "  ██║   ██║██╔══██╗██║     ██║██╔════╝██╔═══██╗██╔════╝"
    echo "  ██║   ██║███████║██║     ██║███████╗██║   ██║███████╗"
    echo "  ╚██╗ ██╔╝██╔══██║██║     ██║╚════██║██║   ██║╚════██║"
    echo "   ╚████╔╝ ██║  ██║███████╗██║███████║╚██████╔╝███████║"
    echo "    ╚═══╝  ╚═╝  ╚═╝╚══════╝╚═╝╚══════╝ ╚═════╝ ╚══════╝"
    echo -e "${NC}"
    echo -e "  ${BLUE}AI Agent-First Linux Distribution${NC}"
    echo ""
}

prompt() {
    local message="$1"
    local default="${2:-}"
    if [[ -n "$default" ]]; then
        echo -en "${GREEN}${message} [${default}]: ${NC}"
    else
        echo -en "${GREEN}${message}: ${NC}"
    fi
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

# ─── Disk Selection ───────────────────────────────────────────────

select_disk() {
    echo ""
    echo -e "${CYAN}=== Disk Selection ===${NC}"
    echo ""
    echo "Available disks:"
    echo ""
    lsblk -d -o NAME,SIZE,MODEL | grep -v loop
    echo ""
    prompt "Target disk (e.g., sda, nvme0n1)"
    read -r DISK
    TARGET_DISK="/dev/${DISK}"

    if [[ ! -b "$TARGET_DISK" ]]; then
        error "Disk $TARGET_DISK not found"
        exit 1
    fi

    echo ""
    warn "This will ERASE ALL DATA on $TARGET_DISK"
    prompt "Are you sure? (yes/no)"
    read -r CONFIRM
    if [[ "$CONFIRM" != "yes" ]]; then
        echo "Aborted."
        exit 0
    fi
}

# ─── GPU Detection ────────────────────────────────────────────────

detect_gpu() {
    echo ""
    echo -e "${CYAN}=== GPU Detection ===${NC}"
    echo ""

    source "${SCRIPT_DIR}/detect-gpu.sh"
    GPU_TYPE=$(detect_gpu)

    case "$GPU_TYPE" in
        nvidia)
            success "Detected NVIDIA GPU"
            lspci | grep -i nvidia
            ;;
        amd)
            success "Detected AMD GPU"
            lspci | grep -iE 'amd|ati|radeon'
            ;;
        intel)
            success "Detected Intel GPU"
            lspci | grep -i intel | grep -i graphics
            ;;
        none)
            info "No dedicated GPU detected — using CPU-only mode"
            ;;
    esac

    echo ""
    info "GPU type will be set to: $GPU_TYPE"
}

# ─── Local LLM ────────────────────────────────────────────────────

configure_llm() {
    echo ""
    echo -e "${CYAN}=== Local LLM Inference ===${NC}"
    echo ""

    LOCAL_LLM="false"
    LLM_MODEL="Qwen/Qwen2.5-Coder-7B-Instruct"

    if [[ "$GPU_TYPE" == "none" ]]; then
        warn "No GPU detected. Local LLM inference requires a GPU."
        warn "You can still use a cloud LLM API (OpenAI, Anthropic, etc.)"
        info "Skipping local LLM setup."
        return
    fi

    echo "A local LLM allows your VALISOS agent to work without internet"
    echo "or cloud API keys. It runs on your GPU using vLLM."
    echo ""
    echo "Recommended models:"
    echo "  1) Qwen2.5-Coder-7B-Instruct  (~4.5 GB, good for code tasks)"
    echo "  2) Llama-3.1-8B-Instruct       (~4.5 GB, general purpose)"
    echo "  3) Mistral-7B-Instruct          (~4.5 GB, general purpose)"
    echo "  4) Skip — I'll use a cloud API"
    echo ""
    prompt "Choose [1-4]" "1"
    read -r LLM_CHOICE

    case "${LLM_CHOICE:-1}" in
        1)
            LOCAL_LLM="true"
            LLM_MODEL="Qwen/Qwen2.5-Coder-7B-Instruct"
            ;;
        2)
            LOCAL_LLM="true"
            LLM_MODEL="meta-llama/Llama-3.1-8B-Instruct"
            ;;
        3)
            LOCAL_LLM="true"
            LLM_MODEL="mistralai/Mistral-7B-Instruct-v0.3"
            ;;
        4)
            LOCAL_LLM="false"
            info "Skipping local LLM. Configure a cloud API in OpenClaw settings later."
            ;;
    esac

    if [[ "$LOCAL_LLM" == "true" ]]; then
        success "Will install vLLM with model: $LLM_MODEL"
        echo ""
        info "The model will be downloaded on first boot (~5 GB)."
        info "Make sure the machine has internet access."
    fi
}

# ─── Tailscale ────────────────────────────────────────────────────

configure_tailscale() {
    echo ""
    echo -e "${CYAN}=== Tailscale Configuration ===${NC}"
    echo ""
    echo "Tailscale provides secure remote access to your VALISOS machine."
    echo "You can set it up now with an auth key, or configure it after first boot."
    echo ""
    prompt "Tailscale auth key (or press Enter to skip)"
    read -r TAILSCALE_KEY
    TAILSCALE_KEY="${TAILSCALE_KEY:-}"
}

# ─── SSH Keys ─────────────────────────────────────────────────────

configure_ssh() {
    echo ""
    echo -e "${CYAN}=== SSH Configuration ===${NC}"
    echo ""
    echo "Add SSH public keys for remote access."
    echo "Paste one key per line. Enter empty line when done."
    echo ""

    SSH_KEYS=()
    while true; do
        prompt "SSH public key (or Enter to finish)"
        read -r KEY
        if [[ -z "$KEY" ]]; then
            break
        fi
        SSH_KEYS+=("$KEY")
        success "Key added"
    done
}

# ─── OpenClaw ─────────────────────────────────────────────────────

configure_openclaw() {
    echo ""
    echo -e "${CYAN}=== OpenClaw Agent Configuration ===${NC}"
    echo ""
    echo "OpenClaw is your AI agent. It connects to a messaging platform"
    echo "so you can talk to your VALISOS machine."
    echo ""
    echo "You can configure the messaging channel after first boot."
    echo "For now, we just need to know your preferred LLM backend."
    echo ""

    if [[ "$LOCAL_LLM" == "true" ]]; then
        info "OpenClaw will be configured to use the local vLLM server."
        OPENCLAW_LLM_BACKEND="local"
    else
        echo "LLM backend options:"
        echo "  1) Anthropic (Claude)"
        echo "  2) OpenAI"
        echo "  3) Other OpenAI-compatible API"
        echo "  4) Configure later"
        echo ""
        prompt "Choose [1-4]" "4"
        read -r OPENCLAW_CHOICE

        case "${OPENCLAW_CHOICE:-4}" in
            1)
                OPENCLAW_LLM_BACKEND="anthropic"
                prompt "Anthropic API key"
                read -r OPENCLAW_API_KEY
                ;;
            2)
                OPENCLAW_LLM_BACKEND="openai"
                prompt "OpenAI API key"
                read -r OPENCLAW_API_KEY
                ;;
            3)
                OPENCLAW_LLM_BACKEND="custom"
                prompt "API base URL"
                read -r OPENCLAW_API_URL
                prompt "API key"
                read -r OPENCLAW_API_KEY
                ;;
            4)
                OPENCLAW_LLM_BACKEND="none"
                info "Configure LLM backend in OpenClaw settings after first boot."
                ;;
        esac
    fi
}

# ─── Generate NixOS Configuration ─────────────────────────────────

generate_config() {
    echo ""
    echo -e "${CYAN}=== Generating NixOS Configuration ===${NC}"
    echo ""

    MOUNT="/mnt"

    info "Partitioning $TARGET_DISK..."
    parted "$TARGET_DISK" -- mklabel gpt
    parted "$TARGET_DISK" -- mkpart ESP fat32 1MiB 512MiB
    parted "$TARGET_DISK" -- set 1 esp on
    parted "$TARGET_DISK" -- mkpart primary 512MiB 100%

    # Determine partition naming (nvme vs sata)
    if [[ "$TARGET_DISK" == *"nvme"* ]]; then
        PART1="${TARGET_DISK}p1"
        PART2="${TARGET_DISK}p2"
    else
        PART1="${TARGET_DISK}1"
        PART2="${TARGET_DISK}2"
    fi

    info "Formatting partitions..."
    mkfs.fat -F 32 -n BOOT "$PART1"
    mkfs.ext4 -L VALISOS "$PART2"

    info "Mounting filesystems..."
    mount "$PART2" "$MOUNT"
    mkdir -p "$MOUNT/boot"
    mount "$PART1" "$MOUNT/boot"

    info "Generating hardware configuration..."
    nixos-generate-config --root "$MOUNT"

    info "Cloning VALISOS configuration..."
    git clone "$VALISOS_REPO" "$MOUNT/etc/nixos/valisos-src"

    # Copy modules into the NixOS config directory
    cp -r "$MOUNT/etc/nixos/valisos-src/modules" "$MOUNT/etc/nixos/"
    cp -r "$MOUNT/etc/nixos/valisos-src/docs" "$MOUNT/etc/nixos/"
    cp "$MOUNT/etc/nixos/valisos-src/flake.nix" "$MOUNT/etc/nixos/"

    # Write hardware-specific settings
    cat >> "$MOUNT/etc/nixos/hardware-overrides.nix" << NIXEOF
{ config, pkgs, lib, ... }:
{
  valisos.gpu.type = "${GPU_TYPE}";
  ${LOCAL_LLM:+valisos.localLLM.enable = ${LOCAL_LLM};}
  ${LOCAL_LLM:+valisos.localLLM.model = "${LLM_MODEL}";}
}
NIXEOF

    # Write SSH keys if provided
    if [[ ${#SSH_KEYS[@]} -gt 0 ]]; then
        local keys_nix=""
        for key in "${SSH_KEYS[@]}"; do
            keys_nix+="    \"${key}\"\n"
        done
        cat >> "$MOUNT/etc/nixos/hardware-overrides.nix" << NIXEOF

  users.users.valisos.openssh.authorizedKeys.keys = [
$(echo -e "$keys_nix")  ];
NIXEOF
    fi

    info "Installing NixOS..."
    nixos-install --root "$MOUNT" --flake "$MOUNT/etc/nixos#valisos${LOCAL_LLM:+-local-llm}"

    # Post-install: configure Tailscale if key provided
    if [[ -n "${TAILSCALE_KEY:-}" ]]; then
        info "Configuring Tailscale..."
        mkdir -p "$MOUNT/var/lib/tailscale"
        # Tailscale auth will happen on first boot via a oneshot service
        cat > "$MOUNT/etc/nixos/tailscale-auth.nix" << TSEOF
{ config, pkgs, lib, ... }:
{
  systemd.services.tailscale-auth = {
    description = "Tailscale Initial Authentication";
    after = [ "tailscaled.service" "network-online.target" ];
    wants = [ "tailscaled.service" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "\${pkgs.tailscale}/bin/tailscale up --authkey=${TAILSCALE_KEY}";
      RemainAfterExit = true;
    };
  };
}
TSEOF
    fi
}

# ─── Summary & Install ────────────────────────────────────────────

show_summary() {
    echo ""
    echo -e "${CYAN}=== Installation Summary ===${NC}"
    echo ""
    echo "  Target disk:     $TARGET_DISK"
    echo "  GPU:             $GPU_TYPE"
    echo "  Local LLM:       ${LOCAL_LLM:-false}"
    [[ "$LOCAL_LLM" == "true" ]] && echo "  LLM Model:       $LLM_MODEL"
    echo "  Tailscale:       ${TAILSCALE_KEY:+configured}${TAILSCALE_KEY:-configure after boot}"
    echo "  SSH keys:        ${#SSH_KEYS[@]} key(s)"
    echo "  OpenClaw LLM:    ${OPENCLAW_LLM_BACKEND:-none}"
    echo ""
}

# ─── Main ─────────────────────────────────────────────────────────

main() {
    banner

    if [[ $EUID -ne 0 ]]; then
        error "This installer must be run as root (use sudo)"
        exit 1
    fi

    select_disk
    detect_gpu
    configure_llm
    configure_tailscale
    configure_ssh
    configure_openclaw
    show_summary

    prompt "Proceed with installation? (yes/no)"
    read -r FINAL_CONFIRM
    if [[ "$FINAL_CONFIRM" != "yes" ]]; then
        echo "Aborted."
        exit 0
    fi

    generate_config

    echo ""
    success "════════════════════════════════════════════"
    success "  VALISOS installed successfully!"
    success "════════════════════════════════════════════"
    echo ""
    info "Remove the installation media and reboot:"
    echo "    reboot"
    echo ""
    info "After reboot, your AI agent will be running."
    info "Connect via Tailscale, RustDesk, or SSH to configure OpenClaw messaging."
    echo ""
}

main "$@"
