{inputs, ...}: {
  basashi = {
    core = {
      hardware = {
        cpu.arch = "znver4";
        gpu.nvidia.enable = true;
        monitors = [
          {
            name = "DP-1";
            res = "2560x1440@170.001";
            pos = {
              x = 0;
              y = 0;
            };
            scale = 1.0;
            VRR = true;
          }
          {
            name = "HDMI-A-1";
            res = "3840x2160@60";
            pos = {
              x = -1440;
              y = 0;
            };
            scale = 1.5;
          }
        ];
      };
      kernel = "custom";
      username = "seal";
      networking = {
        networkmanager.enable = true;
        DoT.enable = true;
      };
    };

    desktop = {
      environment = {
        niri.enable = true;
        rofi.enable = true;
        quickshell.enable = true;
        matugen.enable = true;
      };
      apps = {
        gaming.enable = true;
      };
    };

    services = {
      mullvad.enable = true;
      printing.enable = true;
      polkit.enable = true;
      coolercontrol.enable = true;
      avahi.enable = true;
      plymouth.enable = true;
      sddm.enable = true;
      awww.enable = true;
      swaync.enable = true;
      flatpak.enable = true;
      automounting.enable = true;
      idevices.enable = true;
      g502.enable = true;
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
                  mountOptions = ["umask=0077"];
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    "/" = {
                      mountpoint = "/";
                      mountOptions = ["subvol=root" "compress=zstd:1" "noatime"];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["subvol=nix" "compress-force=zstd:1" "noatime"];
                    };
                    "/var" = {
                      mountpoint = "/var";
                      mountOptions = ["subvol=var" "compress=zstd:1" "noatime" "nodatacow" "nodatasum"];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = ["subvol=home" "compress=zstd:1" "noatime"];
                    };
                    "/var/lib" = {
                      mountpoint = "/var/lib";
                      mountOptions = ["subvol=var/lib" "compress=zstd:1" "noatime"];
                    };
                  };
                };
              };
            };
          };
        };
      };
      swapDevices = [
        {
          device = "/var/swap";
          size = 32 * 1024;
        }
      ];
    }
  ];
}
