{ config, lib, ... }:
let
  inherit (import ../../../utils/partition-helpers.nix) mkBoot mkSwap;
  inherit (lib) mapAttrs filterAttrs optionalAttrs;

  cfg = config.basashi.core.partitioning.disks;
  ext4Disks = filterAttrs (_: d: d.fs == "ext4") cfg;

  # ext4 has no subvolumes, so we need real partitions with fixed sizes
  rootParts = {
    "/" = { size = "5%"; };
    "/nix" = { size = "20%"; };
    "/home" = { size = "100%"; };
  };

  # disko allocates by priority; the remainder must be carved last
  mkPart = mountpoint:
    { size }: {
      inherit size;
      priority = if size == "100%" then 9999 else 1000;
      content = {
        type = "filesystem";
        format = "ext4";
        inherit mountpoint;
      };
    };

  partName = mountpoint: if mountpoint == "/" then "root" else baseNameOf mountpoint;

  mkDisk = disk:
    let
      # non-root disks get a single bare filesystem, unmounted until claimed
      dataParts = if disk.isRoot then
        lib.mapAttrs' (mp: p: lib.nameValuePair (partName mp) (mkPart mp p)) rootParts
      else {
        data = mkPart null { size = "100%"; };
      };
    in {
      inherit (disk) device;
      type = "disk";
      content = {
        type = "gpt";
        partitions = optionalAttrs disk.isRoot { boot = mkBoot { }; }
          // optionalAttrs (disk.swapPartition != null) {
            swap = mkSwap { size = disk.swapPartition; };
          } // dataParts;
      };
    };
in { disko.devices.disk = mapAttrs (_: mkDisk) ext4Disks; }
