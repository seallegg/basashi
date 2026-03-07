{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cfg.core.kernel;
  kernelPackage =
    if cfg == "lts"
    then pkgs.linuxPackages
    else if cfg == "latest"
    then pkgs.linuxPackages_latest
    else if cfg == "custom"
    then pkgs.linuxPackages_zen # i know this isn't quite custom yet but i don't want to work on this right now
    else throw "Kernel: Unknown kernel type!";
in {
  options.cfg.core.kernel = lib.mkOption {
    type = lib.types.enum [
      "latest"
      "lts"
      "custom"
    ];
    default = "latest";
  };
  config.boot.kernelPackages = kernelPackage;
}
