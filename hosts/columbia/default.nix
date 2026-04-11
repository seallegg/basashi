{inputs, ...}: {
  networking.hostName = "columbia";
  system.stateVersion = "25.11";

  boot = {
    initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "sd_mod"];
    kernelModules = ["kvm-amd"];
  };
  hardware.cpu.amd.updateMicrocode = true;

  imports = [
    inputs.disko.nixosModules.disko
    ./partitioning.nix
  ];

  cfg = {
    core = {
      kernel = "custom";
      username = "seal";
      nvidia.enable = true;
    };

    desktop = {
      environment = {
        niri.enable = true;
        rofi.enable = true;
      };
      apps = {
        gaming.enable = true;
        coolercontrol.enable = true;
      };
    };

    services = {
      networking = {
        networkmanager.enable = true;
        DoT.enable = true;
        ipv6.enable = false;
      };
      plymouth.enable = true;
      greetd.enable = true;
      swww.enable = true;
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
}
