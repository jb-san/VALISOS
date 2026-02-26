{ config, pkgs, lib, ... }:

{
  # Tailscale for secure remote access
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # Tailscale is configured during installation via:
  #   sudo tailscale up --authkey=<key>
  # The agent can manage Tailscale state after that.

  environment.systemPackages = [ pkgs.tailscale ];
}
