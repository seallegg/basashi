{ config, lib, ... }:
let
  inherit (import ../../../utils/partition-helpers.nix) mkBoot mkSwap;
  inherit (lib)
    mkOption mkEnableOption mkIf mkMerge types mapAttrs mapAttrs' mapAttrsToList
    groupBy attrValues concatLists filter map head length all unique hasPrefix
    listToAttrs nameValuePair optionalAttrs;

  inherit (config.basashi.core.partitioning) pools;

  # fallback identity for a device with no friendly name: a short stable hash,
  # kept short so derived partlabels stay under the 36-char gpt limit
  diskHash = device:
    "d" + builtins.substring 0 8 (builtins.hashString "sha256" device);

  # a member entry is keyed by either a device path (auto-labeled) or a friendly
  # name (manual label); the name, when given, becomes the partlabel
  mkSpec = pool: role: key: s:
    let byPath = hasPrefix "/" key;
    in s // {
      device = if byPath then key else s.device;
      name = if byPath then null else key;
      inherit pool role;
    };

  poolSpecs = pool: p:
    let mk = role: mapAttrsToList (mkSpec pool role);
    in mk "data" p.members ++ mk "cache" p.cache ++ mk "log" p.log
    ++ mk "spare" p.spare;

  allSpecs = concatLists (attrValues (mapAttrs poolSpecs pools));

  specLabel = s:
    if s.name != null then
      s.name
    else
      "${diskHash s.device}-${s.pool}-${s.role}";
  partlabel = s: "/dev/disk/by-partlabel/${specLabel s}";

  # the disko disk attr-key is readable when a device has a single named member;
  # otherwise it falls back to the hash (e.g. a device shared across pools)
  diskName = device: specs:
    let named = filter (s: s.name != null) specs;
    in if length specs == 1 && named != [ ] then
      (head named).name
    else
      diskHash device;

  # disko: lower priority is carved first, so the 100% remainder must be last
  mkSpecPart = s:
    nameValuePair "${s.pool}-${s.role}" {
      inherit (s) size;
      label = specLabel s;
      priority = if s.size == "100%" then 9999 else 1000;
      content = {
        type = "zfs";
        inherit (s) pool;
      };
    };

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

  # mirror the btrfs subvol scheme; var/var-lib are gone with the swapfile move
  rootDatasets = {
    "/" = "root";
    "/nix" = "nix";
    "/home" = "home";
  };

  mkDataset = mountpoint: opts:
    nameValuePair (rootDatasets.${mountpoint} or (baseNameOf mountpoint)) {
      type = "zfs_fs";
      inherit mountpoint;
      options = { mountpoint = "legacy"; } // opts;
    };

  mkPool = name: p:
    let
      specs = poolSpecs name p;
      labelsOf = role: map partlabel (filter (s: s.role == role) specs);
      data = labelsOf "data";
      cache = labelsOf "cache";
      log = labelsOf "log";
      spare = labelsOf "spare";
      asVdevs = map (m: { members = [ m ]; });

      # a stripe with no aux vdevs lets disko auto-collect; anything else needs
      # an explicit topology so caches/logs do not get striped into the data
      needsTopology = p.mode != null || cache != [ ] || log != [ ] || spare
        != [ ];

      autoRoot = optionalAttrs p.isRoot
        (mapAttrs' (mp: _: mkDataset mp { }) rootDatasets);
      userDatasets =
        mapAttrs' (_: ds: mkDataset ds.mountpoint ds.options) p.datasets;
    in {
      type = "zpool";
      inherit (p) options rootFsOptions;
      mode = if needsTopology then {
        topology = {
          type = "topology";
          vdev = [{
            mode = if p.mode == null then "" else p.mode;
            members = data;
          }];
        } // optionalAttrs (cache != [ ]) { inherit cache; }
          // optionalAttrs (spare != [ ]) { inherit spare; }
          // optionalAttrs (log != [ ]) { log = asVdevs log; };
      } else
        "";
      datasets = autoRoot // userDatasets;
    };

  deviceSpec = types.submodule {
    options = {
      # required only when the entry is keyed by a friendly name, not a /dev path
      device = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      size = mkOption {
        type = types.str;
        default = "100%";
      };
      # an esp / swap partition is carved on this device before its zfs partition
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

  datasetType = types.submodule {
    options = {
      mountpoint = mkOption { type = types.str; };
      options = mkOption {
        type = types.attrsOf types.str;
        default = { };
      };
    };
  };

  isRootPools = filter (p: p.isRoot) (attrValues pools);
  bootSpecs = filter (s: s.boot) allSpecs;
  memberNames = filter (n: n != null) (map (s: s.name) allSpecs);
in {
  options.basashi.core.zfs.enable = mkEnableOption "ZFS support" // {
    default = pools != { };
  };

  options.basashi.core.partitioning.pools = mkOption {
    default = { };
    type = types.attrsOf (types.submodule {
      options = {
        isRoot = mkOption {
          type = types.bool;
          default = false;
        };
        # null stripes the data members; otherwise a single vdev in this mode
        mode = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        members = mkOption {
          type = types.attrsOf deviceSpec;
          default = { };
        };
        cache = mkOption {
          type = types.attrsOf deviceSpec;
          default = { };
        };
        log = mkOption {
          type = types.attrsOf deviceSpec;
          default = { };
        };
        spare = mkOption {
          type = types.attrsOf deviceSpec;
          default = { };
        };
        options = mkOption {
          type = types.attrsOf types.str;
          default = { };
        };
        rootFsOptions = mkOption {
          type = types.attrsOf types.str;
          default = { };
        };
        datasets = mkOption {
          type = types.attrsOf datasetType;
          default = { };
        };
      };
    });
  };

  config = mkMerge [
    {
      disko.devices = {
        disk = mapAttrs' (device: specs:
          nameValuePair (diskName device specs) (mkDisk device specs))
          (groupBy (s: s.device) allSpecs);
        zpool = mapAttrs mkPool pools;
      };

      assertions = [
        # bcachefs/zfs swapfiles deadlock; discovery uses zram + a swap partition
        {
          assertion =
            !(config.basashi.core.swap.file.enable && isRootPools != [ ]);
          message =
            "basashi.partitioning: core.swap.file is enabled with a zfs root pool. zfs swapfiles are deadlock-prone; use core.swap.zram or a swapPartition instead.";
        }
        {
          assertion = length isRootPools <= 1;
          message =
            "basashi.partitioning: more than one zfs pool is marked isRoot.";
        }
        # a zfs root needs exactly one esp; data-only pools need none
        {
          assertion = length bootSpecs == (if isRootPools == [ ] then 0 else 1);
          message =
            "basashi.partitioning: a zfs root pool needs exactly one member with boot = true (and data-only zfs hosts must not set boot).";
        }
        # name-keyed members carry their device in the value
        {
          assertion = all (s: s.device != null) allSpecs;
          message = ''
            basashi.partitioning: a pool member keyed by a name must set device = "/dev/..."; only members keyed by a device path may omit it.'';
        }
        # member names become partlabels, so they must be unique
        {
          assertion = length memberNames == length (unique memberNames);
          message =
            "basashi.partitioning: duplicate pool member name; names become partlabels and must be unique across all pools.";
        }
      ];
    }

    (mkIf config.basashi.core.zfs.enable {
      boot = {
        supportedFilesystems.zfs = true;
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
    })
  ];
}
