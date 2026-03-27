{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.cfg.services.networking;
in {
  options.cfg.services.networking = {
    networkmanager = {
      enable = mkEnableOption "NetworkManager";
    };
    DoT.enable = mkEnableOption "DNS over TLS";
    ipv6.enable = mkEnableOption "IPv6 support"; # my ISP does not support it :im_crine:
  };

  config = {
    networking = {
      networkmanager = {
        enable = cfg.networkmanager.enable;
        wifi.backend = "iwd";
        dns = mkIf cfg.DoT.enable "systemd-resolved";
      };

      enableIPv6 = cfg.ipv6.enable;

      wireless = {
        iwd = {
          enable = true;
          settings = {
            Network = {
              EnableIPv6 = cfg.ipv6.enable;
              EnableNetworkConfiguration = true;
            };
          };
        };
      };
      dhcpcd.enable = false; # both iwd and NM handle this
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
