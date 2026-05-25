{ config, lib, ... }:
let
  cfg = config.basashi;
  inherit (lib) mkIf mkForce mkMerge;
in {
  options.basashi = {
    core.kernelParams = {
      quietBoot.enable = lib.mkEnableOption "quiet boot";
      gaming.enable = lib.mkEnableOption
        "kernel parameters for better latency (mainly gaming), may reduce performance in some workloads (read boot.nix)";
      unsafe.enable =
        lib.mkEnableOption "unsafe kernel parameters for better performance (be careful!)";
    };
    services.plymouth.enable = lib.mkEnableOption "Plymouth splash screen";
  };

  config = mkMerge [
    {
      basashi.core.kernelParams.quietBoot.enable = lib.mkDefault true;

      zramSwap.enable = true;

      boot = {
        loader = {
          systemd-boot = {
            enable = true;
            editor = false; # there is a very dumb vulnerability related to this
            consoleMode = "max";
          };
          efi.canTouchEfiVariables = true;
          timeout = 0; # hold space to access boot menu
        };

        initrd = {
          systemd.enable = true;
          availableKernelModules =
            [ "nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" "ehci_pci" "sdhci_pci" ];
          compressor = "zstd";
          compressorArgs = [ "-1" "-T0" ];
        };

        tmp = {
          useTmpfs = true;
          tmpfsHugeMemoryPages = "within_size";
        };

        kernel.sysctl = {
          "vm.swappiness" = 100; # swap more, we're using zram
          "vm.page-cluster" = 0; # no clustering is better for zram
          "net.core.default_qdisc" = "fq";
          "net.ipv4.tcp_congestion_control" = "bbr";
        };
        kernelParams = [
          "transparent_hugepage=madvise" # always doesn't play well with zram
        ];
      };

      services.lvm.enable = false;
    }

    (mkIf cfg.core.kernelParams.quietBoot.enable {
      boot.kernelParams = [
        "quiet"
        "loglevel=3"
        "rd.udev.log_level=3"
        "systemd.show_status=auto"
        "vt.global_cursor_default=0"
      ];
    })

    (mkIf cfg.core.kernelParams.gaming.enable {
      boot.kernelParams = [ "split_lock_detect=off" ]; # can cause crazy stutters in some games
      boot.kernel.sysctl = {
        "vm.max_map_count" = 2147483642; # this avoids some proton crashes
        # both of these reduce microstutters
        "vm.compaction_proactiveness" = 0;
        "vm.page_lock_unfairness" = 1;
      };
    })

    (mkIf cfg.core.kernelParams.unsafe.enable {
      boot.kernelParams = [
        "nowatchdog"
        "tsc=nowatchdog"
        # it's very debatable whether this is actually useful on zen4. there's an old phoronix article
        # that claims it makes performance worse, but that seems to be related to an old kernel bug.
        # in any case, the architecture is inherently very resistant to meltdown and spectre (intel BTFO)
        # the only reasonable attack vectors in my use cases would either be a malicious program (on nixos?)
        # or a malicious website (through the browser sandbox, which is already very robust).
        # on the other hand, the gain from this from what i've gathered could be just 1-3% in some workloads.
        # tl;dr: i'm not a security researcher, don't quote me or sue me. yolo
        "mitigations=off"
      ];
    })

    (mkIf cfg.services.plymouth.enable {
      basashi.core.kernelParams.quietBoot.enable = mkForce true;
      boot.plymouth = {
        enable = true;
        theme = "bgrt";
      };
    })
  ];
}
