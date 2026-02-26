{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # ISO metadata
  isoImage.isoName = "valisos-installer.iso";
  isoImage.volumeID = "VALISOS";

  # Include the VALISOS installer script
  environment.systemPackages = with pkgs; [
    git
    curl
    neovim
    pciutils
    parted
    dosfstools
    e2fsprogs
    ntfs3g
  ];

  # Copy installer script into the ISO
  environment.etc."valisos-installer/install.sh" = {
    source = ./installer/install.sh;
    mode = "0755";
  };

  environment.etc."valisos-installer/detect-gpu.sh" = {
    source = ./installer/detect-gpu.sh;
    mode = "0755";
  };

  # Welcome message on boot
  services.getty.helpLine = lib.mkForce ''

    ██╗   ██╗ █████╗ ██╗     ██╗███████╗ ██████╗ ███████╗
    ██║   ██║██╔══██╗██║     ██║██╔════╝██╔═══██╗██╔════╝
    ██║   ██║███████║██║     ██║███████╗██║   ██║███████╗
    ╚██╗ ██╔╝██╔══██║██║     ██║╚════██║██║   ██║╚════██║
     ╚████╔╝ ██║  ██║███████╗██║███████║╚██████╔╝███████║
      ╚═══╝  ╚═╝  ╚═╝╚══════╝╚═╝╚══════╝ ╚═════╝ ╚══════╝

    AI Agent-First Linux Distribution

    To install VALISOS, run:
      sudo /etc/valisos-installer/install.sh

  '';
}
