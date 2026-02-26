# VALISOS

**AI Agent-First Linux Distribution**

VALISOS is a NixOS-based Linux distribution where an AI agent is the primary operator. Humans interact with their machine through messaging apps (Telegram, Signal, Discord) via [OpenClaw](https://github.com/openclaw/openclaw), and connect via Tailscale + RustDesk when they need direct access.

## Philosophy

- The AI agent is the primary interface, not the human
- All system state is declarative (NixOS) — reproducible, rollbackable, auditable
- The agent learns how to operate the system from structured markdown documentation
- The system evolves over time as the agent installs, configures, and optimizes

## Architecture

```
Human ──→ Telegram/Signal/Discord ──→ OpenClaw ──→ VALISOS (NixOS)
                                         │
                                    vLLM (local) or Cloud LLM API
```

### Core Components

| Component | Purpose |
|-----------|---------|
| **NixOS** | Declarative, reproducible OS foundation |
| **OpenClaw** | AI agent gateway — connects messaging to system control |
| **vLLM** | Local LLM inference (optional, OpenAI-compatible API) |
| **Tailscale** | Secure mesh VPN for remote access |
| **RustDesk** | Remote desktop for GUI sessions |

### Agent Documentation

The agent reads markdown files at `/etc/valisos/` to understand how to operate the system:

| Document | Purpose |
|----------|---------|
| `SYSTEM.md` | System overview and agent role |
| `MODULES.md` | What's installed and how components connect |
| `GUARDRAILS.md` | Hard rules — what the agent must never do without human approval |
| `CONVENTIONS.md` | How to write Nix modules and follow project patterns |
| `HISTORY.md` | Agent-maintained changelog of all system changes |
| `runbooks/` | Step-by-step procedures for common tasks |

## Installation

1. Download the VALISOS ISO
2. Boot from USB
3. Run the installer:
   ```
   sudo /etc/valisos-installer/install.sh
   ```
4. The installer will:
   - Detect your GPU and configure drivers
   - Ask if you want local LLM inference (requires GPU)
   - Set up Tailscale, SSH keys, and OpenClaw
5. Reboot — your AI agent is live

## Building the ISO

```bash
nix build .#iso
```

## Development

```
VALISOS/
├── flake.nix                     # Main flake
├── modules/
│   ├── core/                     # Base system, networking, users
│   ├── agent/                    # OpenClaw, vLLM, agent docs
│   ├── remote-access/            # Tailscale, RustDesk, SSH
│   └── hardware/                 # GPU auto-detection
├── docs/                         # Agent documentation (deployed to /etc/valisos/)
│   └── runbooks/                 # Step-by-step procedures
├── iso/                          # ISO builder and installer
│   └── installer/                # Installation scripts
├── profiles/                     # System profiles (minimal, local-inference)
└── overlays/                     # Custom package overlays
```

## Requirements

- x86_64 system
- 8 GB RAM minimum (16 GB+ recommended for local LLM)
- NVIDIA, AMD, or Intel GPU (optional, needed for local LLM inference)
- Internet connection (for initial setup and cloud LLM if not using local)

## License

TBD
