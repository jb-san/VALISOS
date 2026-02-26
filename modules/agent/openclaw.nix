{ config, pkgs, lib, ... }:

{
  # OpenClaw - the primary AI agent interface
  #
  # OpenClaw runs as an always-on service, connected to the user's
  # messaging platform. It is the main way humans interact with VALISOS.

  environment.systemPackages = with pkgs; [
    nodejs_22 # OpenClaw runtime
    python3   # For tooling and scripts
  ];

  # OpenClaw Gateway service
  systemd.services.openclaw = {
    description = "OpenClaw AI Agent Gateway";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      HOME = "/var/lib/openclaw";
      NODE_ENV = "production";
    };

    serviceConfig = {
      Type = "simple";
      User = "valisos";
      Group = "users";
      WorkingDirectory = "/var/lib/openclaw";
      ExecStart = "/var/lib/openclaw/start.sh";
      Restart = "always";
      RestartSec = 10;

      # Give OpenClaw access to manage the system
      # It runs as valisos user with passwordless sudo
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
    };
  };

  # OpenClaw state directory
  systemd.tmpfiles.rules = [
    "d /var/lib/openclaw 0755 valisos users -"
  ];

  # OpenClaw configuration is populated during installation:
  # - LLM backend (local vLLM or cloud API)
  # - Messaging channel credentials
  # - Agent system prompt (points to /etc/valisos/SYSTEM.md)
}
