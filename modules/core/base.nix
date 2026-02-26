{ config, pkgs, lib, ... }:

{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel - use latest for best hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Timezone - agent can reconfigure per user preference
  time.timeZone = "UTC";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Essential system packages
  environment.systemPackages = with pkgs; [
    # System essentials
    git
    curl
    wget
    htop
    btop
    tree
    jq
    ripgrep
    fd
    unzip
    zip

    # Editors (for human access)
    neovim
    nano

    # System monitoring
    lsof
    pciutils
    usbutils
    dmidecode

    # Nix tools
    nix-info
    nixos-rebuild

    # Networking diagnostics
    inetutils
    dig
    traceroute
  ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Keep 10 generations for rollback safety
  boot.loader.systemd-boot.configurationLimit = 10;

  # Journal - keep logs accessible for the agent
  services.journald.extraConfig = ''
    SystemMaxUse=2G
    MaxRetentionSec=30day
  '';

  # Minimal desktop environment for RustDesk sessions
  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = "valisos";
  };

  system.stateVersion = "24.11";
}
