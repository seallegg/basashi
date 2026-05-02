{
  config,
  lib,
  ...
}: let
  cfg = config.basashi.services.filesharing.nfs;

  mkNfsExport = name: path: let
    opts = "(rw,nohide,insecure,no_subtree_check,async,no_root_squash)";
    subnetsWithOpts = map (subnet: "${subnet}${opts}") cfg.trustedSubnets;
  in "${path} ${lib.concatStringsSep " " subnetsWithOpts}";

  nfsExports = lib.concatStringsSep "\n" (lib.mapAttrsToList mkNfsExport cfg.shares);
in {
  options.basashi.services.filesharing.nfs = {
    shares = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = {tank = "/mnt/tank";};
      description = "Attribute set mapping share names to directory paths.";
    };
    trustedSubnets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["192.168.1.0/24"];
      description = "List of subnets allowed to access the shares.";
    };
  };

  config = lib.mkIf (cfg.shares != {}) {
    services.nfs.server = {
      enable = true;
      exports = nfsExports;
    };
    networking.firewall.allowedTCPPorts = [2049];
  };
}
