{ ... }: {
  networking.hostId = "7f833560";

  basashi = {
    core = {
      hardware = { cpu.arch = "znver4"; };
      kernel = "cachy-lts";
      networking = {
        defaultGateway = "192.168.0.1";
        DoT.enable = true;
        staticIP = { enp4s0 = "192.168.0.87/24"; };
      };
      username = "admin";
      swap = {
        file.enable = false;
        zram = {
          enable = true;
          algorithm = "zstd";
        };
      };

      # zfs.enable is implied by declaring pools below; root/nix/home datasets
      # are generated automatically for the isRoot pool
      partitioning.pools = {
        rootPool = {
          isRoot = true;
          members.main = {
            device = "/dev/disk/by-id/nvme-KINGSTON_SNV3S500G_50026B7687606BEB";
            boot = true;
            swap = "32G";
          };
          options = {
            ashift = "12";
            autotrim = "on";
          };
          rootFsOptions = {
            compression = "zstd-1";
            atime = "off";
            xattr = "sa";
            acltype = "posixacl";
          };
        };

        tankPool = {
          mode = "raidz1";
          members = {
            hdd1.device =
              "/dev/disk/by-id/ata-WDC_WD80EFPX-68C4ZN0_WD-RD33UTXG";
            hdd2.device =
              "/dev/disk/by-id/ata-WDC_WD80EFPX-68C4ZN0_WD-RD33Z20G";
            hdd3.device =
              "/dev/disk/by-id/ata-WDC_WD80EFPX-68C4ZN0_WD-RD342YSG";
          };
          cache.l2arc = {
            device =
              "/dev/disk/by-id/nvme-KINGSTON_SNV2S1000G_50026B7686C937B8";
            size = "128G";
          };
          options = { ashift = "12"; };
          rootFsOptions = {
            compression = "zstd-3";
            xattr = "sa";
            acltype = "posixacl";
          };
          datasets.tank = { mountpoint = "/mnt/tank"; };
        };

        fastPool = {
          members.fast.device =
            "/dev/disk/by-id/nvme-KINGSTON_SNV2S1000G_50026B7686C937B8";
          options = {
            ashift = "12";
            autotrim = "on";
          };
          rootFsOptions = {
            compression = "zstd-1";
            atime = "off";
            xattr = "sa";
            acltype = "posixacl";
          };
          datasets.fast = { mountpoint = "/mnt/fast"; };
        };
      };
    };

    services = {
      filesharing = {
        nfs = {
          shares = {
            tank = "/mnt/tank";
            fast = "/mnt/fast";
          };
          trustedSubnets = [ "192.168.0.0/24" ];
        };
        samba = {
          shares = { tank = "/mnt/tank"; };
          trustedSubnets = [ "192.168.0.0/24" ];
          interface = "enp4s0";
        };
      };
    };

    terminal = {
      git.name = "SeallEgg";
      git.email = "seallegg@pm.me";
    };
  };
}
