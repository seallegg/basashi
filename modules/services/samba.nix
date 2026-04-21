{
  config,
  lib,
  ...
}: let
  mkSambaShares =
    lib.mapAttrs (name: path: {
      "path" = path;
      "read only" = "no";
      "guest ok" = "yes";
      "force user" = "${config.cfg.core.username}";
    })
    config.cfg.services.samba.shares;
in {
  options.cfg.services.samba.shares = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
    example = {tank = "/mnt/tank";};
    description = "Attribute set mapping share names to directory paths.";
  };

  config = lib.mkIf (config.cfg.services.samba.shares != {}) {
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
            "security" = "user";

            "vfs objects" = "fruit streams_xattr";
            "fruit:metadata" = "stream";
            "fruit:model" = "MacSamba";
            "fruit:posix_rename" = "yes";
            "fruit:veto_appledouble" = "no";
            "fruit:wipe_intentionally_left_blank_rfork" = "yes";
            "fruit:delete_empty_adfiles" = "yes";
          };
        }
        // mkSambaShares;
    };

    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
        userServices = true;
      };
    };
  };
}
