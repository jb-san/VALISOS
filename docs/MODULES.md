# VALISOS Module Reference

This document describes every NixOS module in the VALISOS configuration and how they connect.

## Core Modules

### `modules/core/base.nix`
Base system configuration: bootloader (systemd-boot), latest kernel, essential CLI tools, Nix flakes, garbage collection, journal config, and XFCE desktop (for RustDesk sessions).

### `modules/core/networking.nix`
NetworkManager, firewall rules, mDNS via Avahi. Firewall allows SSH (22), RustDesk (21115-21119), OpenClaw Gateway (18789), and Tailscale (41641 UDP). The `tailscale0` interface is trusted.

### `modules/core/users.nix`
The `valisos` user account with sudo, networkmanager, video, and render groups. Passwordless sudo is enabled so the agent can run system commands without prompts. Shell is zsh.

## Remote Access Modules

### `modules/remote-access/tailscale.nix`
Tailscale mesh VPN. Authenticated during installation. Provides secure remote access without port forwarding.

### `modules/remote-access/rustdesk.nix`
RustDesk remote desktop, runs as a systemd service. Allows the human to get a GUI session on the machine.

### `modules/remote-access/ssh.nix`
OpenSSH with key-only authentication, no root login, X11 forwarding enabled.

## Agent Modules

### `modules/agent/openclaw.nix`
OpenClaw AI agent gateway. Runs as a systemd service on Node.js 22. Connects to the human's messaging platform and to the LLM backend (local vLLM or cloud API).

### `modules/agent/vllm.nix` (optional)
vLLM local inference server. Serves an OpenAI-compatible API on localhost. Configurable model (default: Qwen2.5-Coder-7B-Instruct) and port (default: 8000).

### `modules/agent/agent-docs.nix`
Deploys this documentation to `/etc/valisos/` so the agent can read it at runtime.

## Hardware Modules

### `modules/hardware/gpu.nix`
GPU auto-detection. Supports NVIDIA (proprietary drivers + CUDA), AMD (amdgpu + ROCm), and Intel (compute runtime). Set via `valisos.gpu.type` option during installation.

## Module Dependency Graph

```
base.nix ─────────────────────────────────┐
networking.nix ───────────────────────────┤
users.nix ────────────────────────────────┤
                                          ├─→ NixOS System
tailscale.nix ────────────────────────────┤
rustdesk.nix ──── (needs xserver) ── base.nix
ssh.nix ──────────────────────────────────┤
                                          │
gpu.nix ──────────────────────────────────┤
                                          │
openclaw.nix ── (uses) ──→ vllm.nix (optional)
agent-docs.nix ───────────────────────────┘
```
