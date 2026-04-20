{inputs, ...}: {
  networking.hostName = "discovery";
  networking.hostId = "7f833560";
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
      kernel = "cachy-lts";
      zfs.enable = true;
      username = "admin";
      amdgpu.enable = true;
    };

    services = {
      networking = {
        defaultGateway = "192.168.0.1";
        staticIP = {
          enp4s0 = "192.168.0.87/24";
          wlan0 = "192.168.5.87/24";
        };
        DoT.enable = true;
        IPv6.enable = false;
      };
      networkFileSharing = {
        enable = true;
        shares = {
          tank = "/mnt/tank";
          fast = "/mnt/fast";
        };
        trustedSubnets = [
          "192.168.0.0/24"
          "192.168.5.0/24"
        ];
      };
    };

    terminal = {
      git.name = "SeallEgg";
      git.email = "seallegg@gmail.com";
    };
  };
}
