{inputs, ...}: {
  networking.hostName = "challenger";
  system.stateVersion = "25.11";

  boot.initrd.availableKernelModules = ["nvme" "ehci_pci" "xhci_pci" "sdhci_pci"];
  hardware.cpu.amd.updateMicrocode = true;
  services.libinput.enable = true; # touchpad

  imports = [
    inputs.disko.nixosModules.disko
    ./partitioning.nix
  ];

  cfg = {
    core = {
      kernel = "custom";
      username = "seal";
      amdgpu.enable = true;
      hibernation = {
        enable = true;
        resumeDevice = "/dev/disk/by-id/nvme-eui.5cdfb8038100270a-part2";
        resumeOffset = "18442029";
      };
    };

    desktop = {
      environment = {
        niri.enable = true;
        rofi.enable = true;
        matugen.enable = true;
      };
      apps = {
        gaming.enable = true;
      };
    };

    services = {
      networking = {
        networkmanager.enable = true;
        DoT.enable = true;
        mullvad.enable = true;
      };
      avahi.enable = true;
      plymouth.enable = true;
      powersaving.enable = true;
      sddm.enable = true;
      awww.enable = true;
      swaync.enable = true;
      automounting.enable = true;
    };
    terminal = {
      git.name = "SeallEgg";
      git.email = "seallegg@gmail.com";
    };
  };
}
