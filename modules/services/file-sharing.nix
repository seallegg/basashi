{
  config,
  lib,
  ...
}: let
  cfg = config.cfg.services.networkFileSharing;

  mkSambaShares =
    lib.mapAttrs (name: path: {
      "path" = path;
      "read only" = "no";
      "guest ok" = "yes";
      "force create mod" = "0755";
      "force user" = "${config.cfg.core.username}";
    })
    cfg.shares;

  mkNfsExport = name: path: let
    opts = "(rw,nohide,insecure,no_subtree_check,async,no_root_squash)";
    subnetsWithOpts = map (subnet: "${subnet}${opts}") cfg.trustedSubnets;
  in "${path} ${lib.concatStringsSep " " subnetsWithOpts}";

  nfsExports = lib.concatStringsSep "\n" (lib.mapAttrsToList mkNfsExport cfg.shares);
in {
  options.cfg.services.networkFileSharing = {
    enable = lib.mkEnableOption "Network File Sharing (Samba & NFS)";
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

  config = lib.mkIf cfg.enable {
    services.samba = {
      enable = true;
      openFirewall = true;
      settings =
        {
          global = {
            "invalid users" = ["root"];
            "passwd program" = "/run/wrappers/bin/passwd %u";
            "server role" = "standalone server";
            "map to guest" = "Bad user";
            "usershare allow guests" = "yes";
            "hosts allow" = "192.168.0.0/16";
            "hosts deny" = "0.0.0.0/0";
            security = "user";
          };
        }
        // mkSambaShares;
    };

    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    services.nfs.server = {
      enable = true;
      exports = nfsExports;
    };
    networking.firewall.allowedTCPPorts = [2049];
  };
}
