{ config, lib, ... }:
let
  inherit (import ../../../utils/partition-helpers.nix) mkBoot mkSwap;
  inherit (lib) any attrValues filterAttrs mapAttrs optional optionalAttrs;

  cfg = config.basashi.core.partitioning.disks;
  btrfsDisks = filterAttrs (_: d: d.fs == "btrfs") cfg;

  rootSubvols = {
    "/" = { subvol = "root"; }; # actual "/" will stay free for impermanence later
    "/nix" = { force = true; };
    "/home" = { };
  };

  mkSubvolSet = compression: hasSwapPart:
    let
      mkSubvol = path:
        { subvol ? path, force ? false, compress ? true, extra ? [ ] }:
        let
          mode = if force then "compress-force" else "compress";
          compressOpts = optional (compress && compression != null) "${mode}=${compression}";
        in {
          mountpoint = path;
          mountOptions = [ "subvol=${subvol}" "noatime" ] ++ compressOpts ++ extra;
        };

      # swapfile lives here when there's no swap partition; no compression or CoW
      subvols = rootSubvols // optionalAttrs (!hasSwapPart) {
        "/swap" = {
          compress = false;
          extra = [ "nodatacow" "nodatasum" ];
        };
      };
    in mapAttrs mkSubvol subvols;

  mkDisk = disk: {
    inherit (disk) device;
    type = "disk";
    content = {
      type = "gpt";
      partitions = optionalAttrs disk.isRoot { boot = mkBoot { }; }
        // optionalAttrs (disk.swapPartition != null) {
          swap = mkSwap { size = disk.swapPartition; };
        } // {
          root = {
            size = "100%";
            priority = 9999;
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = if disk.isRoot then
                mkSubvolSet disk.compression (disk.swapPartition != null)
              else
                { };
            };
          };
        };
    };
  };
in {
  disko.devices.disk = mapAttrs (_: mkDisk) btrfsDisks;

  # the default swapfile needs /swap to be a subvolume, which can only exist
  # when the root disk has no swap partition; the two are mutually exclusive
  assertions = [{
    assertion = !(config.basashi.core.swap.file.enable
      && any (d: d.isRoot && d.swapPartition != null) (attrValues btrfsDisks));
    message =
      "basashi.partitioning: root disk has swap partition, but core.swap.file is enabled (swapfile is in /swap/file and requires /swap to be writeale). disable the swapfile or drop swapPartition on the root disk.";
  }];
}
