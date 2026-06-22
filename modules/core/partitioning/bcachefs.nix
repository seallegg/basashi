{ config, lib, ... }:
let
  inherit (import ../../../utils/partition-helpers.nix) mkBoot mkSwap;
  inherit (lib)
    mkOption types mapAttrs mapAttrs' mapAttrsToList groupBy attrValues
    concatLists filter map head length all unique hasPrefix listToAttrs
    nameValuePair optional optionalAttrs;

  inherit (config.basashi.core.partitioning) bcachefs;

  # fallback identity for a device with no friendly name: a short stable hash,
  # kept short so derived partlabels stay under the 36-char gpt limit
  diskHash = device:
    "d" + builtins.substring 0 8 (builtins.hashString "sha256" device);

  # a member is keyed by either a device path (auto-labeled) or a friendly name
  mkSpec = filesystem: key: m:
    let byPath = hasPrefix "/" key;
    in m // {
      device = if byPath then key else m.device;
      pname = if byPath then null else key;
      inherit filesystem;
    };

  fsSpecs = name: fs: mapAttrsToList (mkSpec name) fs.members;
  allSpecs = concatLists (attrValues (mapAttrs fsSpecs bcachefs));

  partName = s: if s.pname != null then s.pname else diskHash s.device;
  # the tiering group defaults to the partition name, so it is never the empty
  # string disko would otherwise pass as a bare `--label=`
  tierLabel = s: if s.label != "" then s.label else partName s;

  # disko: lower priority is carved first, so the 100% remainder must be last
  mkSpecPart = s:
    nameValuePair (partName s) {
      inherit (s) size;
      priority = if s.size == "100%" then 9999 else 1000;
      content = {
        type = "bcachefs";
        inherit (s) filesystem;
        label = tierLabel s;
      };
    };

  # readable disk attr-key when a device has a single named member, else a hash
  diskName = device: specs:
    let named = filter (s: s.pname != null) specs;
    in if length specs == 1 && named != [ ] then
      (head named).pname
    else
      diskHash device;

  # one gpt disk per physical device, collecting every partition destined for it
  mkDisk = device: specs:
    let
      bootSpecs = filter (s: s.boot) specs;
      swapSpecs = filter (s: s.swap != null) specs;
    in {
      inherit device;
      type = "disk";
      content = {
        type = "gpt";
        partitions = optionalAttrs (bootSpecs != [ ]) { boot = mkBoot { }; }
          // optionalAttrs (swapSpecs != [ ]) {
            swap = mkSwap { size = (head swapSpecs).swap; };
          } // listToAttrs (map mkSpecPart specs);
      };
    };

  # mirror the btrfs subvol scheme; "/" keeps the "root" subvol so it can be left
  # unmounted for impermanence later. no swap subvol: bcachefs has no swapfile
  # support (mkswap rejects its extents), so /persist is the only addition
  rootSubvols = {
    "/" = "root";
    "/nix" = "nix";
    "/home" = "home";
  };

  mkSubvol = name: mountpoint: mountOptions:
    nameValuePair name {
      inherit name mountpoint;
      mountOptions = mountOptions ++ [ "noatime" ];
    };

  mkFilesystem = _: fs:
    let
      autoSubvols = optionalAttrs fs.isRoot
        (mapAttrs' (mp: n: mkSubvol n mp [ ]) rootSubvols);
      userSubvols =
        mapAttrs (n: s: (mkSubvol n s.mountpoint s.mountOptions).value)
        fs.subvolumes;
    in {
      type = "bcachefs_filesystem";
      extraFormatArgs =
        optional (fs.compression != null) "--compression=${fs.compression}"
        ++ optional (fs.backgroundCompression != null)
        "--background_compression=${fs.backgroundCompression}"
        ++ optional (fs.foregroundTarget != null)
        "--foreground_target=${fs.foregroundTarget}"
        ++ optional (fs.backgroundTarget != null)
        "--background_target=${fs.backgroundTarget}"
        ++ optional (fs.promoteTarget != null)
        "--promote_target=${fs.promoteTarget}"
        ++ optional (fs.metadataTarget != null)
        "--metadata_target=${fs.metadataTarget}"
        ++ optional (fs.replicas != null) "--replicas=${toString fs.replicas}"
        ++ fs.extraFormatArgs;
      subvolumes = autoSubvols // userSubvols;
    };

  deviceSpec = types.submodule {
    options = {
      # required only when the entry is keyed by a friendly name, not a /dev path
      device = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      # tiering group (e.g. "ssd"/"hdd"); defaults to the member name
      label = mkOption {
        type = types.str;
        default = "";
      };
      size = mkOption {
        type = types.str;
        default = "100%";
      };
      # an esp / swap partition is carved on this device before its bcachefs one
      boot = mkOption {
        type = types.bool;
        default = false;
      };
      swap = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
  };

  subvolType = types.submodule {
    options = {
      mountpoint = mkOption { type = types.str; };
      mountOptions = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };

  targetOpt = mkOption {
    type = types.nullOr types.str;
    default = null;
  };

  isRootFs = filter (fs: fs.isRoot) (attrValues bcachefs);
  bootSpecs = filter (s: s.boot) allSpecs;
  memberNames = filter (n: n != null) (map (s: s.pname) allSpecs);
in {
  options.basashi.core.partitioning.bcachefs = mkOption {
    default = { };
    type = types.attrsOf (types.submodule {
      options = {
        isRoot = mkOption {
          type = types.bool;
          default = false;
        };
        members = mkOption {
          type = types.attrsOf deviceSpec;
          default = { };
        };
        # tiering targets reference member labels
        foregroundTarget = targetOpt;
        backgroundTarget = targetOpt;
        promoteTarget = targetOpt;
        metadataTarget = targetOpt;
        compression = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        backgroundCompression = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        replicas = mkOption {
          type = types.nullOr types.ints.positive;
          default = null;
        };
        extraFormatArgs = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
        subvolumes = mkOption {
          type = types.attrsOf subvolType;
          default = { };
        };
      };
    });
  };

  config = {
    disko.devices = {
      disk = mapAttrs' (device: specs:
        nameValuePair (diskName device specs) (mkDisk device specs))
        (groupBy (s: s.device) allSpecs);
      bcachefs_filesystems = mapAttrs mkFilesystem bcachefs;
    };

    assertions = [
      # bcachefs cannot swap to a file (mkswap rejects its extents); use zram or
      # a swap partition instead
      {
        assertion = !(config.basashi.core.swap.file.enable && isRootFs != [ ]);
        message =
          "basashi.partitioning: core.swap.file is enabled with a bcachefs root. bcachefs has no swapfile support; use core.swap.zram or a swapPartition instead.";
      }
      # a bcachefs root needs exactly one esp; data-only filesystems need none
      {
        assertion = length bootSpecs == (if isRootFs == [ ] then 0 else 1);
        message =
          "basashi.partitioning: a bcachefs root needs exactly one member with boot = true (and data-only bcachefs hosts must not set boot).";
      }
      # name-keyed members carry their device in the value
      {
        assertion = all (s: s.device != null) allSpecs;
        message = ''
          basashi.partitioning: a bcachefs member keyed by a name must set device = "/dev/..."; only members keyed by a device path may omit it.'';
      }
      # member names back the disk attr-key / partlabel, so they must be unique
      {
        assertion = length memberNames == length (unique memberNames);
        message =
          "basashi.partitioning: duplicate bcachefs member name; names must be unique across all filesystems.";
      }
    ];
  };
}
