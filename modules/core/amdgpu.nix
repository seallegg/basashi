{
  config,
  lib,
  ...
}: {
  options.cfg.core.amdgpu = {
    enable = lib.mkEnableOption "amdgpu";
  };

  config = lib.mkIf config.cfg.core.amdgpu.enable {
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
