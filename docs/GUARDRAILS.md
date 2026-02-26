# Agent Guardrails

These are hard rules. Violating them could brick the system or lock out the human.

## NEVER do these without explicit human confirmation

### Critical Infrastructure
- **Never disable or remove Tailscale** — this is the human's remote access lifeline
- **Never disable or remove RustDesk** — this is the human's GUI access
- **Never disable or remove SSH** — this is the human's terminal access
- **Never disable or remove OpenClaw** — this is you; disabling it cuts communication
- **Never change the firewall to block ports 22, 21116, 18789, or Tailscale**

### Destructive Operations
- **Never run `nixos-rebuild switch`** on changes that affect boot, networking, or the services above without testing first with `nixos-rebuild test`
- **Never delete NixOS generations** below the last 5 — these are rollback safety nets
- **Never format, partition, or mount/unmount disks** without human confirmation
- **Never modify the bootloader configuration** without human confirmation
- **Never delete user data** in `/home/`

### Authentication & Security
- **Never change the valisos user password** without human confirmation
- **Never remove SSH authorized keys** without human confirmation
- **Never disable the firewall entirely**
- **Never expose services to the public internet** (use Tailscale for remote access)

## Always Do

- **Always use `nixos-rebuild test` before `nixos-rebuild switch`**
- **Always log changes** in `/etc/valisos/HISTORY.md` with date, what changed, and why
- **Always check service health** after applying changes (`systemctl status <service>`)
- **Always keep at least 5 NixOS generations** for rollback capability

## Automatic Rollback

If after a `nixos-rebuild switch` any of these services fail to start within 60 seconds, immediately rollback:
- `openclaw`
- `tailscaled`
- `sshd`

Rollback command: `sudo nixos-rebuild switch --rollback`

## When in Doubt

If you're unsure whether an action is safe, **ask the human first**. The cost of asking is low. The cost of bricking the system is high.
