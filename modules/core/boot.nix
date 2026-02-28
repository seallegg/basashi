{hostConfig, ...}: {
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0; # hold space to access boot menu
    };
    initrd.systemd.enable = true;
    kernelParams = map (m: "video=${m.name}:${m.res}") hostConfig.monitors;

    tmp = {
      useTmpfs = true;
      tmpfsSize = "50%";
    };
  };
  services.swapspace.enable = true;
  zramSwap.enable = true;

  hardware.enableRedistributableFirmware = true;
}
