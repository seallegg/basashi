{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.cfg.services.networking;
in {
  options.cfg.services.networking = {
    staticIP = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = {
        eno1 = "192.168.1.100/24";
      };
      description = "Attribute set mapping specified interface names to static IP addresses.";
    };
    defaultGateway = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "192.168.1.1";
      description = "Default gateway address for the system.";
    };
    networkmanager = {
      enable = mkEnableOption "NetworkManager";
    };
    DoT.enable = mkEnableOption "DNS over TLS";
    IPv6.enable = mkEnableOption "IPv6 support"; # my ISP does not support it :im_crine:
  };

  config = {
    networking = {
      dhcpcd.enable = false; # both iwd and NM handle this

      networkmanager = {
        enable = cfg.networkmanager.enable;
        wifi.backend = "iwd";
        dns = mkIf cfg.DoT.enable "systemd-resolved";
      };

      interfaces =
        lib.mapAttrs (name: ip: {
          useDHCP = false;
          ipv4.addresses = [
            {
              address = builtins.head (lib.splitString "/" ip);
              prefixLength = lib.toInt (builtins.elemAt (lib.splitString "/" ip) 1);
            }
          ];
        })
        cfg.staticIP;
      defaultGateway = mkIf (cfg.defaultGateway != null) cfg.defaultGateway;

      enableIPv6 = cfg.IPv6.enable;

      wireless = {
        iwd = {
          enable = true;
          settings = {
            Network = {
              EnableIPv6 = cfg.IPv6.enable;
              EnableNetworkConfiguration = true;
            };
          };
        };
      };
    };
    users.users.${config.cfg.core.username} = mkIf cfg.networkmanager.enable {extraGroups = ["networkmanager"];};
    programs.nm-applet.enable = cfg.networkmanager.enable;
    systemd.services.ModemManager.enable = false;
    services.resolved = mkIf cfg.DoT.enable {
      enable = true;
      settings.Resolve = {
        DNS = [
          "45.90.28.0#a772b8.dns.nextdns.io"
          "2a07:a8c0::#a772b8.dns.nextdns.io"
          "45.90.30.0#a772b8.dns.nextdns.io"
          "2a07:a8c1::#a772b8.dns.nextdns.io"
        ];
        DNSOverTLS = "yes";
      };
    };
  };
}
