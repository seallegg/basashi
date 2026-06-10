{ inputs, ... }: {
  services.libinput.enable = true; # touchpad

  basashi = {
    core = {
      hardware = {
        cpu.arch = "znver3";
        gpu.amd.enable = true;
        monitors = [{
          name = "eDP-1";
          res = "1920x1080@60";
          pos = {
            x = 0;
            y = 0;
          };
          scale = 1.125;
        }];
      };
      kernel = "latest";
      username = "seal";
      networking = {
        DoT.enable = true;
        networkmanager.enable = true;
      };
      swap.zram.enable = true;
    };

    desktop = {
      apps = { gaming.enable = true; };
      environment = {
        matugen.enable = true;
        niri.enable = true;
        rofi.enable = true;
      };
    };

    services = {
      automounting.enable = true;
      avahi.enable = true;
      awww.enable = true;
      hibernation = {
        enable = true;
        resumeDevice = "/dev/disk/by-id/nvme-eui.5cdfb8038100270a-part2";
        resumeOffset = "18442029";
      };
      pipewire.enable = true;
      plymouth.enable = true;
      polkit.enable = true;
      powersaving.enable = true;
      printing.enable = true;
      sddm.enable = true;
      swaync.enable = true;
    };
    terminal = {
      fish.enable = true;
      rusty.enable = true;
      ohMyPosh.enable = true;
      agents.enable = true;
      git.name = "SeallEgg";
      git.email = "seallegg@pm.me";
    };
  };

  # partitioning
  imports = [
    inputs.disko.nixosModules.disko
    {
      disko.devices = {
        disk.main = {
          device = "/dev/disk/by-id/nvme-eui.5cdfb8038100270a";
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
  ];
}
