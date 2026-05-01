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
      "browseable" = "yes";
      "force user" = "${config.basashi.core.username}";
    })
    config.basashi.services.samba.shares;
in {
  options.basashi.services.samba.shares = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
    example = {tank = "/mnt/tank";};
    description = "Attribute set mapping share names to directory paths.";
  };

  config = lib.mkIf (config.basashi.services.samba.shares != {}) {
    services.samba = {
      enable = true;
      openFirewall = true;
      settings =
        {
          global = {
            "workgroup" = "WORKGROUP";
            "server string" = "Samba Server";
            "netbios name" = "${config.networking.hostName}";
            "invalid users" = ["root"];
            "passwd program" = "/run/wrappers/bin/passwd %u";
            "server role" = "standalone server";
            "map to guest" = "Bad user";
            "usershare allow guests" = "yes";
            "hosts allow" = "192.168.0.0/16 127.0.0.1 localhost";
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

    services.avahi.extraServiceFiles.smb = ''
      <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
      <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
      <service-group>
        <name replace-wildcards="yes">%h</name>
        <service>
          <type>_smb._tcp</type>
          <port>445</port>
        </service>
        <service>
          <type>_device-info._tcp</type>
          <port>0</port>
          <txt-record>model=MacSamba</txt-record>
        </service>
      </service-group>
    '';

    systemd.tmpfiles.rules = lib.mapAttrsToList (name: path: "d ${path} 0775 ${config.basashi.core.username} users - -") config.basashi.services.samba.shares;

    basashi.services.avahi.enable = true;
  };
}
