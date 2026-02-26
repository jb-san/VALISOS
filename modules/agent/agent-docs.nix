{ config, pkgs, lib, ... }:

{
  # Deploy agent documentation to /etc/valisos/
  #
  # These markdown files are the agent's "manual" for understanding
  # and operating the system. OpenClaw reads these on startup and
  # references them when performing tasks.

  environment.etc = {
    "valisos/SYSTEM.md" = {
      source = ../../docs/SYSTEM.md;
      mode = "0644";
    };
    "valisos/MODULES.md" = {
      source = ../../docs/MODULES.md;
      mode = "0644";
    };
    "valisos/GUARDRAILS.md" = {
      source = ../../docs/GUARDRAILS.md;
      mode = "0644";
    };
    "valisos/CONVENTIONS.md" = {
      source = ../../docs/CONVENTIONS.md;
      mode = "0644";
    };
    "valisos/HISTORY.md" = {
      source = ../../docs/HISTORY.md;
      mode = "0666"; # Agent-writable
    };
    "valisos/runbooks/install-package.md" = {
      source = ../../docs/runbooks/install-package.md;
      mode = "0644";
    };
    "valisos/runbooks/add-service.md" = {
      source = ../../docs/runbooks/add-service.md;
      mode = "0644";
    };
    "valisos/runbooks/update-system.md" = {
      source = ../../docs/runbooks/update-system.md;
      mode = "0644";
    };
    "valisos/runbooks/manage-users.md" = {
      source = ../../docs/runbooks/manage-users.md;
      mode = "0644";
    };
    "valisos/runbooks/gpu-setup.md" = {
      source = ../../docs/runbooks/gpu-setup.md;
      mode = "0644";
    };
  };
}
