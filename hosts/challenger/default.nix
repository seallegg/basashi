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
        IPv6.enable = false;
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
