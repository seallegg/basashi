# this may or may not be 70% snake oil
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cfg.core.kernel;
  kernelArch =
    if config.cfg.hardware.arch == "znver4"
    then "zen4"
    else "x86_64-v3"; # really not going to use this on anything older

  kernelPackage =
    if cfg == "lts"
    then pkgs.linuxPackages_lts
    else if cfg == "latest"
    then pkgs.linuxPackages_latest
    else if cfg == "cachy-lts"
    then pkgs.cachyosKernels."linuxPackages-cachyos-lts-lto-${kernelArch}"
    else if cfg == "cachy-latest"
    then pkgs.cachyosKernels."linuxPackages-cachyos-latest-lto-${kernelArch}"
    else
      pkgs.linuxPackagesFor (
        pkgs.cachyosKernels.linux-cachyos-latest.override {
          pname = "linux-cachyos-basashi";
          processorOpt = "${kernelArch}";
          lto = "thin";
          hugepages = "madvise"; # always (cachy default) doesn't play well with zram
          autoModules = false;
        }
      );
in {
  options.cfg.core.kernel = lib.mkOption {
    type = lib.types.enum [
      "lts"
      "latest"
      "cachy-lts"
      "cachy-latest"
      "custom"
    ];
    default = "latest";
    description = "Kernel type to use";
  };
  config = {
    nixpkgs.overlays = [inputs.cachyos-kernel.overlays.default];
    boot.kernelPackages = kernelPackage;
  };
}
