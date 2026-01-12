{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.cfg.core.nvidia;
in {
  options.cfg.core.nvidia = {
    enable = mkEnableOption "nvidia";
  };

  config = mkIf cfg.enable {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };

      nvidia = {
        modesetting.enable = true;
        open = true;
        nvidiaSettings = false;
      };
    };

    services.xserver.videoDrivers = ["nvidia"];
    nixpkgs.config.cudaSupport = true;

    environment.sessionVariables = {
      __GL_SYNC_TO_VBLANK = "0";
      __GL_VRR_ALLOWED = "1";
      __GL_MaxFramesAllowed = "1";
      CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
    };

    boot = {
      initrd.kernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ];
      kernelParams = mkMerge [
        [
          "nvidia.NVreg_UsePageAttributeTable=1"
          "nvidia.NVreg_EnableResizableBar=1"
          "nvidia.NVreg_RegistryDwords=RmEnableAggressiveVblank=1" # low-latency stuff
          "nvidia_modeset.disable_vrr_memclk_switch=1" # stop really high memclk when vrr is in use.
        ]
        (mkIf config.hardware.nvidia.powerManagement.enable [
          "nvidia.NVreg_TemporaryFilePath=/var/tmp" # store on disk, not /tmp which is on RAM
          "nvidia.NVreg_EnableS0ixPowerManagement=0"
        ])
      ];
    };
  };
}
