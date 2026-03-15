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
      kernel = "latest";
      username = "seal";
      amdgpu.enable = true;
    };

    desktop = {
      environment = {
        niri.enable = true;
        rofi.enable = true;
      };
      apps = {
        gaming.enable = true;
        thunderbird.enable = true;
      };
    };

    services = {
      plymouth.enable = true;
      networkmanager.enable = true;
      powersaving.enable = true;
      swww.enable = true;
      sddm.enable = true;
      swaync.enable = true;
      automounting.enable = true;
    };
    terminal = {
      git.name = "SeallEgg";
      git.email = "seallegg@gmail.com";
    };
  };
}
