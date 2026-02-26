# Runbook: Manage Users

## Add a New User

1. Edit `modules/core/users.nix`:
   ```nix
   users.users.<username> = {
     isNormalUser = true;
     description = "<Full Name>";
     extraGroups = [ "wheel" "networkmanager" ];
     initialPassword = "<temporary-password>";
     shell = pkgs.zsh;
   };
   ```

2. Test: `sudo nixos-rebuild test`
3. Apply: `sudo nixos-rebuild switch`
4. Inform the human of the temporary password and ask them to change it.

## Add SSH Key for a User

1. Edit `modules/remote-access/ssh.nix` or the user definition:
   ```nix
   users.users.<username>.openssh.authorizedKeys.keys = [
     "ssh-ed25519 AAAA... user@host"
   ];
   ```

2. Test and apply as above.

## Remove a User

**Requires human confirmation** (see GUARDRAILS.md).

1. Remove the user block from `modules/core/users.nix`
2. Test and apply
3. User home directory is preserved — only delete with explicit human permission

## Grant Sudo Access

Add `"wheel"` to the user's `extraGroups` list.
