# Runbook: Add a New Service

## Steps

1. Create a new module file at `modules/services/<service-name>.nix`:
   ```nix
   { config, pkgs, lib, ... }:
   {
     options.valisos.<serviceName> = {
       enable = lib.mkEnableOption "<service description>";
     };

     config = lib.mkIf config.valisos.<serviceName>.enable {
       environment.systemPackages = [ pkgs.<package> ];

       systemd.services.<service-name> = {
         description = "<Service Description>";
         after = [ "network-online.target" ];
         wants = [ "network-online.target" ];
         wantedBy = [ "multi-user.target" ];
         serviceConfig = {
           ExecStart = "${pkgs.<package>}/bin/<binary>";
           Restart = "always";
           RestartSec = 5;
         };
       };
     };
   }
   ```

2. Add the module to `flake.nix` in the modules list.

3. Enable the service in the configuration:
   ```nix
   valisos.<serviceName>.enable = true;
   ```

4. Test: `sudo nixos-rebuild test`

5. Apply: `sudo nixos-rebuild switch`

6. Verify:
   ```
   systemctl status <service-name>
   journalctl -u <service-name> --no-pager -n 50
   ```

7. Update `/etc/valisos/MODULES.md` with the new service description.

8. Log the change in `/etc/valisos/HISTORY.md`.

## Rollback

```
sudo nixos-rebuild switch --rollback
```
