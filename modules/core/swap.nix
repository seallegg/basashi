{ config, lib, ... }:
let
  inherit (lib) mkDefault mkEnableOption mkMerge mkOption mkIf types;
  cfg = config.basashi.core.swap;
  zrAlgo = cfg.zram.algorithm;
  zramSwappinessDefault = if zrAlgo == "lz4" then 160 else if zrAlgo == "zstd-1" then 140 else 120;
  zramSizeDefault = if zrAlgo == "zstd" then 240 else if zrAlgo == "zstd-1" then 200 else 165;
in {
  options.basashi.core.swap = {
    file = {
      enable = mkEnableOption "swapfile on /var/swap (must be properly formatted in btrfs)";
      size = mkOption {
        type = types.int;
        default = 16;
        description = "size of the swapfile in GiB";
      };
    };
    zram = {
      enable = mkEnableOption "primary swap on zram, a compressed block device placed in RAM";
      algorithm = mkOption {
        type = types.enum [ "lz4" "zstd" "zstd-1" ];
        default = "zstd-1";
        description = ''
          Compression algorithm for zram.
          Approximate ratios (my experience): zstd ~2.1×, zstd-1 ~1.8×, lz4 ~1.6×.'';
      };
      size = mkOption {
        type = types.int;
        default = zramSizeDefault;
        description = ''
          Maximum size for uncompressed data in zram as a percentage of total system memory.
          Ideally something like the algorithm compression ratio * 85'';
      };
      writeback = {
        enable = mkEnableOption "sending incompressible pages from zram to a block device";
        device = mkOption {
          type = types.str;
          default = "/var/swap";
        };
      };
    };
    zswap = {
      enable = mkEnableOption
        "compressed swap cache placed in memory, in front of swap (not a swap device)";
      algorithm = mkOption {
        type = types.enum [ "lz4" "zstd" ];
        default = "zstd";
        description = ''
          Compression algorithm for zswap.
          Approximate ratios (my experience): zstd ~2.1×, lz4 ~1.6×.'';
      };
      size = mkOption {
        type = types.int;
        default = 50;
        description = "Maximum percentage of total memory taken up by zswap.";
      };
      writeback = {
        enable = mkEnableOption "sending pages to swap at all.";
        device = mkOption {
          type = types.str;
          default = "/var/swap";
        };
      };
    };

    # NOTE:
    # the way swappiness is used by the linux kernel has been broken since MGLRU was merged in version 6.1
    # there is a path for the kernel 7.1-rc1 which changes this behavior at https://github.com/firelzrd/re-swappiness
    # I will be moving toward using this in custom kernel builds eventually
    swappiness = mkOption {
      type = types.int;
      default = 60;
      description = ''
        Kernel preference for swapping to evicting cache from memory (and thus reading the originals disk).
        Ideal value should be equal to swapwrite/diskread+swapwrite * 200.
        If swap is on the same disk the cache is from, this should be <100, as reads are faster than writes on the same disk.
        If swap is on zram, this should be >100, as zram writes are faster than disk reads.
        Best values for zram vary with hardware & algorithm. They should be tested empirically; defaults are acceptable.
        Zswap has no impact on what this should be set to.'';
    };
  };

  config = mkMerge [
    {
      basashi.core.swap.file.enable = mkDefault true;
      boot.kernel.sysctl."vm.swappiness" = cfg.swappiness;
    }

    (mkIf cfg.file.enable {
      swapDevices = [{
        device = "/var/swap";
        size = cfg.file.size * 1024;
      }];
    })

    (mkIf cfg.zram.enable {
      zramSwap = {
        enable = true;
        algorithm = if zrAlgo == "zstd-1" then "zstd(level=-1)" else zrAlgo;
        memoryPercent = cfg.zram.size;
      };

      boot = {
        kernel.sysctl."vm.pagecluster" = 0;
        kernelParams = [ "transparent_hugepage=madvise" ];
        tmp.tmpfsHugeMemoryPages = "within_size";
      };

      basashi.core.swap.swappiness = mkDefault zramSwappinessDefault;
    })

    (mkIf cfg.zswap.enable {
      # zswap usually requires an active swap device
      basashi.core.swap.file.enable = mkDefault true;

      boot = {
        zswap = {
          enable = true;
          compressor = cfg.zswap.algorithm;
          maxPoolPercent = cfg.zswap.size;
        };
        kernelParams = mkIf (!cfg.zswap.writeback.enable) [ "zswap.writeback=0" ];
      };
    })
  ];
}
