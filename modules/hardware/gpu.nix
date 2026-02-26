{ config, pkgs, lib, ... }:

{
  # GPU auto-detection and driver configuration
  #
  # This module detects the GPU at build time and configures
  # the appropriate drivers. The installer sets the correct
  # option based on hardware detection.

  options.valisos.gpu = {
    type = lib.mkOption {
      type = lib.types.enum [ "none" "nvidia" "amd" "intel" ];
      default = "none";
      description = "Detected GPU type for driver and compute configuration";
    };
  };

  config = lib.mkMerge [
    # NVIDIA GPU configuration
    (lib.mkIf (config.valisos.gpu.type == "nvidia") {
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        modesetting.enable = true;
        open = false; # Use proprietary drivers for best compute support
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };

      hardware.graphics.enable = true;

      # CUDA support for vLLM
      environment.systemPackages = with pkgs; [
        cudaPackages.cudatoolkit
        cudaPackages.cudnn
      ];
    })

    # AMD GPU configuration
    (lib.mkIf (config.valisos.gpu.type == "amd") {
      services.xserver.videoDrivers = [ "amdgpu" ];
      hardware.graphics.enable = true;

      # ROCm for vLLM
      hardware.amdgpu.opencl.enable = true;
      environment.systemPackages = with pkgs; [
        rocmPackages.rocm-smi
      ];
    })

    # Intel GPU configuration
    (lib.mkIf (config.valisos.gpu.type == "intel") {
      services.xserver.videoDrivers = [ "modesetting" ];
      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          intel-compute-runtime
        ];
      };
    })
  ];
}
