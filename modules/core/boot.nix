{
  config,
  lib,
  ...
}: {
  options.basashi.services.plymouth.enable = lib.mkEnableOption "Plymouth splash screen";

  config = {
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        timeout = 0; # hold space to access boot menu
      };
      initrd = {
        systemd.enable = true;
        availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" "ehci_pci" "sdhci_pci"];
        compressor = "zstd";
        compressorArgs = ["-1" "-T0"];
      };

      plymouth = lib.mkIf config.basashi.services.plymouth.enable {
        enable = true;
        theme = "bgrt";
      };

      kernelParams = [
        "quiet"
        "loglevel=3"
        "rd.udev.log_level=3"
        "systemd.show_status=auto"
        "vt.global_cursor_default=0"
      ];

      tmp = {
        useTmpfs = true;
        tmpfsSize = "50%";
        tmpfsHugeMemoryPages = "within_size";
      };
    };
    zramSwap = {
      enable = true;
      algorithm = "lz4";
    };
    services.lvm.enable = false;
  };
}
