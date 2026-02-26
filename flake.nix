{
  description = "VALISOS - AI Agent-First Linux Distribution";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # ISO generation
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true; # For NVIDIA drivers
      };
    in
    {
      # The main NixOS configuration for a VALISOS machine
      nixosConfigurations.valisos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/core/base.nix
          ./modules/core/networking.nix
          ./modules/core/users.nix
          ./modules/remote-access/tailscale.nix
          ./modules/remote-access/rustdesk.nix
          ./modules/remote-access/ssh.nix
          ./modules/agent/openclaw.nix
          ./modules/agent/agent-docs.nix
          ./modules/hardware/gpu.nix
        ];
      };

      # Configuration with local LLM inference enabled
      nixosConfigurations.valisos-local-llm = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/core/base.nix
          ./modules/core/networking.nix
          ./modules/core/users.nix
          ./modules/remote-access/tailscale.nix
          ./modules/remote-access/rustdesk.nix
          ./modules/remote-access/ssh.nix
          ./modules/agent/openclaw.nix
          ./modules/agent/agent-docs.nix
          ./modules/agent/vllm.nix
          ./modules/hardware/gpu.nix
        ];
      };

      # ISO image for installation
      packages.${system}.iso = nixos-generators.nixosGenerate {
        inherit system;
        modules = [
          ./iso/default.nix
        ];
        format = "iso";
      };
    };
}
