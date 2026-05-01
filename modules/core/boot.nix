{
  config,
  lib,
  ...
}: {
  options.basashi.services.plymouth.enable = lib.mkEnableOption "Plymouth";

  config = {
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        timeout = 0; # hold space to access boot menu
      };
      initrd = {
        systemd.enable = true;
        compressor = "zstd";
        compressorArgs = ["-1" "-T0"];
      };

      plymouth = lib.mkIf config.basashi.services.plymouth.enable {
        enable = true;
        theme = "bgrt";
      };

      kernelParams =
        [
          "quiet"
          "loglevel=3"
          "rd.udev.log_level=3"
          "systemd.show_status=auto"
          "vt.global_cursor_default=0"
        ]
        ++ (map (m: "video=${m.name}:${m.res}") config.basashi.hardware.monitors);

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
    services.lvm.enable = false; # why this is on by default is beyond me
    hardware.enableRedistributableFirmware = true;
  };
}
