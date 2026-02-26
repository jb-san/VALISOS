{ config, pkgs, lib, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false; # Keys only
      PermitRootLogin = "no";
      X11Forwarding = true; # Allow GUI forwarding if needed
    };
  };

  # SSH keys are added during installation or by the agent
  # The agent can manage authorized_keys for the valisos user
}
