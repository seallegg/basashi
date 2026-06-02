# this may or may not be 70% snake oil
{ config, lib, pkgs, ... }:
let
  cfg = config.basashi.core.kernel;
  kernelArch = if config.basashi.core.hardware.cpu.arch == "znver4" then
    "zen4"
  else
    "x86_64-v3"; # really not going to use this on anything older

  kernelPackage = if cfg == "lts" then
    pkgs.linux
  else if cfg == "latest" then
    pkgs.linuxPackages_latest
  else if cfg == "cachy-lts" then
    pkgs.cachyosKernels."linuxPackages-cachyos-lts-lto-${kernelArch}"
  else if cfg == "cachy-latest" then
    pkgs.cachyosKernels."linuxPackages-cachyos-latest-lto-${kernelArch}"
  else
    pkgs.linuxPackagesFor (pkgs.cachyosKernels.linux-cachyos-latest.override {
      pname = "linux-cachyos-basashi";
      processorOpt = "${kernelArch}";
      lto = "thin";
      hugepage = if config.basashi.core.swap.zram.enable then "madvise" else "always";
      autoModules = false;
    });
in {
  options.basashi.core.kernel = lib.mkOption {
    type = lib.types.enum [ "lts" "latest" "cachy-lts" "cachy-latest" "custom" ];
    default = "latest";
    description = "Kernel type to use";
  };
  config = {
    nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" "https://cache.garnix.io" ];
    nix.settings.trusted-public-keys = [
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];

    boot.kernelPackages = kernelPackage;
  };
}
