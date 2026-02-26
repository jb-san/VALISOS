{ config, pkgs, lib, ... }:

{
  # vLLM - local LLM inference server
  #
  # Provides an OpenAI-compatible API on localhost that OpenClaw
  # uses as its LLM backend. Optional - only included when the
  # user chooses local inference during installation.

  options.valisos.localLLM = {
    enable = lib.mkEnableOption "local LLM inference via vLLM";

    model = lib.mkOption {
      type = lib.types.str;
      default = "Qwen/Qwen2.5-Coder-7B-Instruct";
      description = "HuggingFace model ID to serve";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
      description = "Port for the OpenAI-compatible API";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional arguments to pass to vLLM";
    };
  };

  config = lib.mkIf config.valisos.localLLM.enable {
    environment.systemPackages = [
      pkgs.python312Packages.vllm
    ];

    # vLLM inference server
    systemd.services.vllm = {
      description = "vLLM Inference Server";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        HOME = "/var/lib/vllm";
        HF_HOME = "/var/lib/vllm/huggingface";
      };

      serviceConfig = {
        Type = "simple";
        User = "valisos";
        Group = "users";
        WorkingDirectory = "/var/lib/vllm";
        ExecStart = lib.concatStringsSep " " ([
          "${pkgs.python312Packages.vllm}/bin/vllm"
          "serve"
          config.valisos.localLLM.model
          "--host" "127.0.0.1"
          "--port" (toString config.valisos.localLLM.port)
          "--api-key" "valisos-local" # Local-only, no real auth needed
        ] ++ config.valisos.localLLM.extraArgs);
        Restart = "always";
        RestartSec = 15;

        # vLLM needs GPU access
        SupplementaryGroups = [ "video" "render" ];
      };
    };

    # State directory for model weights cache
    systemd.tmpfiles.rules = [
      "d /var/lib/vllm 0755 valisos users -"
      "d /var/lib/vllm/huggingface 0755 valisos users -"
    ];

    # Open the port on localhost only (firewall not needed for loopback)
    # But add it to firewall if Tailscale access is desired
    networking.firewall.allowedTCPPorts = [ config.valisos.localLLM.port ];
  };
}
