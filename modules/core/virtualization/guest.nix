{ config, lib, ... }:
let
  cfg = config.basashi.core.virtualization.guest;
  inherit (lib) mkEnableOption mkIf mkMerge mkOption optionals types;

  sharedTuning = {
    virtualisation = {
      memorySize = cfg.memory * 1024;
      inherit (cfg) cores graphics;
      sharedDirectories = mkIf (cfg.sharedDirectory != null) {
        host = {
          source = cfg.sharedDirectory;
          target = "/mnt/host";
        };
      };

      qemu.options = [
        "-device virtio-balloon,free-page-reporting=on" # guest hands idle pages back to host
      ] ++ optionals cfg.graphics [
        # virgl 3d acceleration
        "-vga none"
        "-device virtio-vga-gl"
        "-display gtk,gl=on"
      ];
    };

    # graceful shutdown, clipboard sharing, auto display resize, etc
    services = {
      qemuGuest.enable = true;
      spice-vdagentd.enable = true;
    };

    boot = {
      initrd.availableKernelModules = [ "virtio_pci" "virtio_blk" "virtio_scsi" ];

      # serial console so headless guests are watchable without a display
      # serial is primary (last) for headless access; tty0 still gets boot & GUI
      kernelParams = [ "console=tty0" "console=ttyS0,115200n8" ];
    };
  };
in {
  options.basashi.core.virtualization.guest = {
    enable = mkEnableOption "guest integration and general setup for running this host inside a vm";

    memory = mkOption {
      type = types.ints.positive;
      default = 8;
      description =
        "RAM (GiB) ceiling for the guest. Qemu backs pages lazily and the guest's virtio-balloon reports idle pages back.";
    };
    cores = mkOption {
      type = types.ints.positive;
      default = 4;
      description = "vCPUs handed to the build-vm guest.";
    };
    diskSize = mkOption {
      type = types.ints.positive;
      default = 8192;
      description = "Overlay disk size (MiB) for the build-vm guest.";
    };
    graphics = mkOption {
      type = types.bool;
      default = true;
      description = "Show a graphical qemu window. False gives a headless serial console.";
    };
    sharedDirectory = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/home/seal";
      description = ''
        Host path exposed read/write at /mnt/host inside the build-vm guest over 9p.
        Null disables the share.
      '';
    };
  };

  # these ONLY apply to a vm build of this host, never bare metal
  config = mkIf cfg.enable {
    virtualisation.vmVariant = mkMerge [ sharedTuning { virtualisation.diskSize = cfg.diskSize; } ];

    virtualisation.vmVariantWithDisko = sharedTuning;
  };
}
