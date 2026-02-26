# VALISOS Conventions

Follow these conventions when modifying the system configuration.

## NixOS Configuration

### File Organization
- One module per concern: networking, users, GPU, etc.
- Modules live in `modules/<category>/<name>.nix`
- Categories: `core`, `agent`, `remote-access`, `hardware`, `services`
- New user-requested services go in `modules/services/`

### Naming
- Module files: lowercase, hyphen-separated (`my-service.nix`)
- NixOS options under the `valisos.*` namespace
- Systemd services: match the software name (`vllm`, `openclaw`)

### Options Pattern
When creating configurable modules, use NixOS options:

```nix
options.valisos.myService = {
  enable = lib.mkEnableOption "description of service";
  port = lib.mkOption {
    type = lib.types.port;
    default = 8080;
    description = "Port for the service";
  };
};

config = lib.mkIf config.valisos.myService.enable {
  # ... configuration here
};
```

### Making Changes
1. Edit the relevant module file
2. If adding a new module, add it to `flake.nix` in the modules list
3. Test with `sudo nixos-rebuild test`
4. Apply with `sudo nixos-rebuild switch`
5. Verify services: `systemctl status <service>`
6. Log the change in HISTORY.md

## Agent Documentation

### Runbooks
- One runbook per task in `docs/runbooks/`
- Format: numbered steps, with exact commands
- Include verification steps (how to confirm it worked)
- Include rollback steps (how to undo if it didn't)

### History Log
Format for `/etc/valisos/HISTORY.md` entries:

```
## YYYY-MM-DD HH:MM UTC

**Action:** Brief description of what changed
**Reason:** Why the change was made
**Files modified:** List of changed files
**Verification:** How it was verified
```
