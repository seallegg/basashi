{ config, lib, ... }:
let
  cfg = config.basashi.services.filesharing.samba;
  mkSambaShares = lib.mapAttrs (name: path: {
    "path" = path;
    "read only" = "no";
    "guest ok" = "yes";
    "browseable" = "yes";
    "force user" = "${config.basashi.core.username}";
  }) cfg.shares;
in {
  options.basashi.services.filesharing.samba = {
    shares = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = { tank = "/mnt/tank"; };
      description = "Attribute set mapping share names to directory paths.";
    };
    trustedSubnets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "192.168.1.0/24" ];
      description = "Subnets allowed to connect to Samba (hosts allow).";
    };
    interface = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "enp4s0";
      description = "Interface samba-wsdd should announce on. Null = auto-detect.";
    };
  };

  config = lib.mkIf (cfg.shares != { }) {
    services.samba = {
      enable = true;
      openFirewall = true;
      nmbd.enable = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "Samba Server";
          "netbios name" = "${config.networking.hostName}";
          "invalid users" = [ "root" ];
          "passwd program" = "/run/wrappers/bin/passwd %u";
          "server role" = "standalone server";
          "map to guest" = "Bad user";
          "usershare allow guests" = "yes";
          "hosts allow" =
            lib.concatStringsSep " " (cfg.trustedSubnets ++ [ "127.0.0.1" "localhost" ]);
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
      } // mkSambaShares;
    };

    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
      workgroup = "WORKGROUP";
      interface = lib.mkIf (cfg.interface != null) cfg.interface;
    };

    systemd.tmpfiles.rules =
      lib.mapAttrsToList (name: path: "d ${path} 0775 ${config.basashi.core.username} users - -")
      cfg.shares;

    basashi.services.avahi.enable = true;
  };
}
