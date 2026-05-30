{ inputs, ... }: {
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
      zfs.enable = true;
      swap = {
        file.enable = false;
        zram = {
          enable = true;
          algorithm = "zstd";
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
        samba.shares = { tank = "/mnt/tank"; };
      };
    };

    terminal = {
      git.name = "SeallEgg";
      git.email = "seallegg@gmail.com";
    };
  };

  # partitioning
  imports = [
    inputs.disko.nixosModules.disko
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
                  mountOptions = [ "umask=0077" ];
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
            mode = {
              topology = {
                type = "topology";
                vdev = [{
                  mode = "raidz1";
                  members = [ "hdd1" "hdd2" "hdd3" ];
                }];
                cache = [ "l2arc" ];
              };
            };
            options = { ashift = "12"; };
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
  ];
}
