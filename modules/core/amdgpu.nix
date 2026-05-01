{
  config,
  lib,
  ...
}: {
  options.basashi.core.amdgpu = {
    enable = lib.mkEnableOption "amdgpu";
  };

  config = lib.mkIf config.basashi.core.amdgpu.enable {
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
