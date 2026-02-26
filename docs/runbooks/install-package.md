# Runbook: Install a Package

## Declarative (Permanent) Installation

This is the preferred method. The package becomes part of the system configuration.

### Steps

1. Identify the package name:
   ```
   nix search nixpkgs <search-term>
   ```

2. Edit `/etc/nixos/modules/core/base.nix` (for system tools) or create a new module in `/etc/nixos/modules/services/` (for services):
   ```nix
   environment.systemPackages = with pkgs; [
     # ... existing packages
     new-package-name
   ];
   ```

3. Test the configuration:
   ```
   sudo nixos-rebuild test
   ```

4. If test succeeds, apply:
   ```
   sudo nixos-rebuild switch
   ```

5. Verify the package is available:
   ```
   which <binary-name>
   ```

6. Log the change in `/etc/valisos/HISTORY.md`

## Temporary (Ephemeral) Installation

For trying something out without modifying system config:
```
nix shell nixpkgs#<package-name>
```

This is lost on next reboot.

## Rollback

If the package causes issues:
```
sudo nixos-rebuild switch --rollback
```
