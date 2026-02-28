{inputs, ...}: {
  networking.hostName = "challenger";
  system.stateVersion = "25.11";

  imports = [
    inputs.disko.nixosModules.disko
    ./partitioning.nix
    ./options.nix
  ];

  boot.initrd.availableKernelModules = ["nvme" "ehci_pci" "xhci_pci" "sdhci_pci"];
  hardware.cpu.amd.updateMicrocode = true;

  services.libinput.enable = true; # touchpad
}
