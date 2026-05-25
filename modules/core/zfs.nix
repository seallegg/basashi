{ config, inputs, lib, pkgs, ... }: {
  options.basashi.core.zfs = { enable = lib.mkEnableOption "ZFS support"; };

  config = lib.mkIf config.basashi.core.zfs.enable {
    boot = {
      supportedFilesystems = [ "zfs" ];
      zfs = {
        package = config.boot.kernelPackages.zfs_cachyos;
        forceImportAll = true;
        forceImportRoot = true;
      };
    };

    services.zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };
  };
}
