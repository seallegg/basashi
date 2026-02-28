{inputs, ...}: {
  networking.hostName = "columbia";
  system.stateVersion = "25.11";

  imports = [
    inputs.disko.nixosModules.disko
    ./partitioning.nix
    ./options.nix
  ];

  boot = {
    initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "sd_mod"];
    kernelModules = ["kvm-amd"];
  };
  hardware.cpu.amd.updateMicrocode = true;
}
