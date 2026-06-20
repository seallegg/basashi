{ ... }: {
  services.libinput.enable = true; # touchpad

  basashi = {
    core = {
      partitioning.disks.main = {
        device = "/dev/disk/by-id/nvme-eui.5cdfb8038100270a";
        compression = "zstd:1";
      };
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
          scale = 1.0;
        }];
      };
      kernel = "cachy-latest";
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
        # stale: swapfile moved from /var/swap to /swap/file, re-measure after repartition
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
}
