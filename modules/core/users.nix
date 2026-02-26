{ config, pkgs, lib, ... }:

{
  # Primary user account
  users.users.valisos = {
    isNormalUser = true;
    description = "VALISOS System User";
    extraGroups = [
      "wheel"         # sudo access
      "networkmanager" # network management
      "docker"         # container access (if docker enabled)
      "video"          # GPU access
      "render"         # GPU render access
    ];
    # Password set during installation
    initialPassword = "valisos-change-me";
    shell = pkgs.zsh;
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;

  # Passwordless sudo for the valisos user
  # The agent needs to run system commands without interactive prompts
  security.sudo.extraRules = [
    {
      users = [ "valisos" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
