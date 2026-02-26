# Runbook: Update the System

## Steps

1. Update flake inputs:
   ```
   cd /etc/nixos
   sudo nix flake update
   ```

2. Review what changed:
   ```
   nix flake metadata
   ```

3. Test the update:
   ```
   sudo nixos-rebuild test
   ```

4. Check that critical services are running:
   ```
   systemctl status openclaw tailscaled sshd rustdesk
   ```

5. If all services are healthy, apply permanently:
   ```
   sudo nixos-rebuild switch
   ```

6. Re-check services after switch:
   ```
   systemctl status openclaw tailscaled sshd rustdesk
   ```

7. Log the update in `/etc/valisos/HISTORY.md`.

## Automatic Rollback

If critical services fail within 60 seconds of switch:
```
sudo nixos-rebuild switch --rollback
```

## Cleaning Old Generations

Keep at least 5 generations, then clean:
```
sudo nix-env --delete-generations +5 --profile /nix/var/nix/profiles/system
sudo nix-collect-garbage
```
