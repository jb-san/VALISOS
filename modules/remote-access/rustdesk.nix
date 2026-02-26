{ config, pkgs, lib, ... }:

{
  # RustDesk for remote desktop access
  environment.systemPackages = [ pkgs.rustdesk ];

  # RustDesk runs as a systemd service so it's always available
  systemd.services.rustdesk = {
    description = "RustDesk Remote Desktop";
    after = [ "network-online.target" "graphical.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.rustdesk}/bin/rustdesk --service";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
