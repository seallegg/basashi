{ pkgs, ... }:
{
  # god knows why this can´t be installed as a user package
  environment.systemPackages = [ pkgs.obs-studio ];

  basashi = {
    presets = [ "desktop" "locale" "terminal" ];

    core = {
      username = "seal";
      kernel = "custom";
      hardware = {
        cpu.type = "amd";
        cpu.arch = "znver4";
        gpu.nvidia.enable = true;
        monitors = [
          {
            name = "DP-1";
            res = "2560x1440@170.001";
            VRR = true;
          }
          {
            name = "HDMI-A-1";
            res = "3840x2160@60";
            pos.x = -1440;
            scale = 1.5;
          }
        ];
      };
      swap.zram.algorithm = "lz4";
      kernelParams = {
        unsafe.enable = true;
        gaming.enable = true;
      };
      virtualization.libvirt.enable = true;
    };

    desktop = {
      apps.gaming = {
        steam.enable = true;
        steam.ckan.enable = true;
        minecraft.enable = true;
      };
    };

    services = {
      coolercontrol.enable = true;
      filesharing.nfs.mounts = {
        "/mnt/tank" = "192.168.0.87:/mnt/tank";
        "/mnt/fast" = "192.168.0.87:/mnt/fast";
      };
      g502.enable = true;
      idevices.enable = true;
      pipewire.noJackDetectAlc4080 = true;
    };
  };

  boot.kernelModules = [ "nct6775" ];

  # partitioning
  disko.devices = {
    disk.main = {
      device = "/dev/disk/by-id/nvme-Corsair_MP700_A72XB402003VYB";
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
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/" = {
                  mountpoint = "/";
                  mountOptions = [ "subvol=root" "compress=zstd:1" "noatime" ];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "subvol=nix" "compress-force=zstd:1" "noatime" ];
                };
                "/var" = {
                  mountpoint = "/var";
                  mountOptions =
                    [ "subvol=var" "compress=zstd:1" "noatime" "nodatacow" "nodatasum" ];
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = [ "subvol=home" "compress=zstd:1" "noatime" ];
                };
                "/var/lib" = {
                  mountpoint = "/var/lib";
                  mountOptions = [ "subvol=var/lib" "compress=zstd:1" "noatime" ];
                };
              };
            };
          };
        };
      };
    };
  };
}
