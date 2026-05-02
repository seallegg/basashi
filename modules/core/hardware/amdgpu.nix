{
  config,
  lib,
  ...
}: {
  options.basashi.core.hardware.gpu.amd = {
    enable = lib.mkEnableOption "amdgpu";
  };

  config = lib.mkIf config.basashi.core.hardware.gpu.amd.enable {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };
      amdgpu.initrd.enable = true;
    };
    services.xserver.videoDrivers = ["amdgpu"];
  };
}
