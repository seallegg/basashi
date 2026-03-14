{config, ...}: {
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0; # hold space to access boot menu
    };
    initrd.systemd.enable = true;
    kernelParams = map (m: "video=${m.name}:${m.res}") config.cfg.hardware.monitors;

    tmp = {
      useTmpfs = true;
      tmpfsSize = "50%";
      tmpfsHugeMemoryPages = "within_size"; # not sure how much of a difference this makes
    };
  };
  zramSwap = {
    enable = true;
    algorithm = "lz4";
  };

  hardware.enableRedistributableFirmware = true;
}
