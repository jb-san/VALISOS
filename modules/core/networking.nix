{ config, pkgs, lib, ... }:

{
  networking = {
    hostName = "valisos";

    # NetworkManager for flexibility - agent can manage connections
    networkmanager.enable = true;

    # Firewall - allow essential services, agent can open more as needed
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22    # SSH
        21115 # RustDesk relay
        21116 # RustDesk
        21117 # RustDesk
        21118 # RustDesk
        21119 # RustDesk
        18789 # OpenClaw Gateway WebSocket
      ];
      allowedUDPPorts = [
        21116 # RustDesk
        41641 # Tailscale direct connections
      ];
      # Tailscale interface is trusted
      trustedInterfaces = [ "tailscale0" ];
    };
  };

  # mDNS for local network discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };
}
