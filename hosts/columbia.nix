{ ... }: {
  basashi = {
    core = {
      partitioning.disks.main = {
        device = "/dev/disk/by-id/nvme-Corsair_MP700_A72XB402003VYB";
        compression = "zstd:1";
      };
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
        DoT.enable = true;
        networkmanager.enable = true;
      };
      swap.zram = {
        enable = true;
        algorithm = "lz4";
      };
      kernelParams = {
        unsafe.enable = true;
        gaming.enable = true;
      };
    };

    desktop = {
      apps = { gaming.enable = true; };
      environment = {
        matugen.enable = true;
        niri.enable = true;
        quickshell.enable = true;
        rofi.enable = true;
      };
    };

    services = {
      automounting.enable = true;
      avahi.enable = true;
      awww.enable = true;
      coolercontrol.enable = true;
      filesharing.nfs.mounts = {
        "/mnt/tank" = "192.168.0.87:/mnt/tank";
        "/mnt/fast" = "192.168.0.87:/mnt/fast";
      };
      flatpak.enable = true;
      g502.enable = true;
      idevices.enable = true;
      pipewire.enable = true;
      plymouth.enable = true;
      polkit.enable = true;
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

  boot.kernelModules = [ "nct6775" ];
}
