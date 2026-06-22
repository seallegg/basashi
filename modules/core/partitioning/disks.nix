{ config, lib, ... }:
let
  inherit (lib) attrNames filterAttrs length mapAttrs mkOption types;
  cfg = config.basashi.core.partitioning.disks;
  roots = filterAttrs (_: d: d.isRoot) cfg;
in {
  options.basashi.core.partitioning.disks = mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        compression = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        device = mkOption { type = types.str; };
        # zfs/bcachefs are pool/fs-centric: they declare devices inline in
        # basashi.core.partitioning.{pools,bcachefs}, not through this registry
        fs = mkOption {
          type = types.enum [ "btrfs" "ext4" ];
          default = "btrfs";
        };
        isRoot = mkOption {
          type = types.bool;
          default = false;
        };
        label = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        swapPartition = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
      };
    });
    # lone disk is root; throw on >1 root
    apply = disks:
      let
        disks' = if length (attrNames disks) == 1 then
          mapAttrs (_: d: d // { isRoot = true; }) disks
        else
          disks;
      in if length (attrNames (filterAttrs (_: d: d.isRoot) disks')) > 1 then
        throw
        "basashi.partitioning: more than one disk is marked root (isRoot = true)!"
      else
        disks';
  };

  # exactly one root, unless the module is unused (no disks declared)
  config.assertions = [{
    assertion = cfg == { } || length (attrNames roots) == 1;
    message =
      "basashi.partitioning: exactly one disk must be root (isRoot = true); found ${
        toString (length (attrNames roots))
      }.";
  }];
}
