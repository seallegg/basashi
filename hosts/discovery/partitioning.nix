{lib, ...}:
# sudo nix --experimental-features "nix-command flakes" run 'github:nix-community/disko/latest#disko-install' -- --flake 'github:SeallEgg/basashi#discovery'
{
  disko.devices = {
    disk.main = {
      device = "/dev/disk/by-id/nvme-KINGSTON_SNV3S500G_50026B7687606BEB";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };
          swap = {
            size = "32G";
            content.type = "swap";
          };
          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "rootPool";
            };
          };
        };
      };
    };

    disk.secondary = {
      device = "/dev/disk/by-id/nvme-KINGSTON_SNV2S1000G_50026B7686C937B8";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          l2arc = {
            size = "128G";
            content = {
              type = "zfs";
              pool = "tankPool";
              vdev_role = "cache";
            };
          };
          fast = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "fastPool";
            };
          };
        };
      };
    };

    disk.hdd1 = {
      device = "/dev/disk/by-id/ata-WDC_WD80EFPX-68C4ZN0_WD-RD33UTXG";
      type = "disk";
      content = {
        type = "gpt";
        partitions.zfs = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "tankPool";
          };
        };
      };
    };
    disk.hdd2 = {
      device = "/dev/disk/by-id/ata-WDC_WD80EFPX-68C4ZN0_WD-RD33Z20G";
      type = "disk";
      content = {
        type = "gpt";
        partitions.zfs = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "tankPool";
          };
        };
      };
    };
    disk.hdd3 = {
      device = "/dev/disk/by-id/ata-WDC_WD80EFPX-68C4ZN0_WD-RD342YSG";
      type = "disk";
      content = {
        type = "gpt";
        partitions.zfs = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "tankPool";
          };
        };
      };
    };

    zpool = {
      rootPool = {
        type = "zpool";
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
        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              mountpoint = "legacy";
              atime = "off";
              compression = "zstd-1";
            };
          };
          var = {
            type = "zfs_fs";
            mountpoint = "/var";
            options = {
              mountpoint = "legacy";
              checksum = "off";
            };
          };
          "var/lib" = {
            type = "zfs_fs";
            mountpoint = "/var/lib";
            options = {
              mountpoint = "legacy";
              checksum = "on";
            };
          };
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
            options.mountpoint = "legacy";
          };
        };
      };

      tankPool = {
        type = "zpool";
        mode = "raidz1";
        rootFsOptions = {
          compression = "zstd-3";
          xattr = "sa";
          acltype = "posixacl";
        };
        datasets = {
          tank = {
            type = "zfs_fs";
            mountpoint = "/mnt/tank";
            options.mountpoint = "legacy";
          };
        };
      };

      fastPool = {
        type = "zpool";
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
        datasets = {
          fast = {
            type = "zfs_fs";
            mountpoint = "/mnt/fast";
            options.mountpoint = "legacy";
          };
        };
      };
    };
  };
}
