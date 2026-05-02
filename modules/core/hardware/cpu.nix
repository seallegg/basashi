{
  config,
  lib,
  ...
}: let
  cfg = config.basashi.core.hardware.cpu;
in {
  options.basashi.core.hardware.cpu = {
    type = lib.mkOption {
      type = lib.types.enum ["amd" "intel"];
      default = "amd";
      description = "The type of CPU in the system.";
    };
    arch = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The microarchitecture for tuning (e.g., znver4).";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.type == "amd") {
      hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
      hardware.enableRedistributableFirmware = lib.mkDefault true;
      boot.kernelModules = ["kvm-amd"];
    })
    (lib.mkIf (cfg.type == "intel") {
      hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
      hardware.enableRedistributableFirmware = lib.mkDefault true;
      boot.kernelModules = ["kvm-intel"];
    })
  ];
}
