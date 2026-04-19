{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  options.cfg.core.zfs = {
    enable = lib.mkEnableOption "ZFS support";
  };

  config = lib.mkIf config.cfg.core.zfs.enable {
    nixpkgs.overlays = [inputs.cachyos-kernel.overlays.default];
    boot = {
      supportedFilesystems = ["zfs"];
      zfs.package = config.boot.kernelPackages.zfs_cachyos;
    };

    services.zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };
  };
}
