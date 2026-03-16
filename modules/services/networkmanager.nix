{
  config,
  lib,
  ...
}: {
  options.cfg.services.networkmanager.enable = lib.mkEnableOption "NetworkManager";
  config = lib.mkIf config.cfg.services.networkmanager.enable {
    programs.nm-applet.enable = true;
    networking = {
      networkmanager = {
        enable = true;
        wifi = {
          macAddress = "stable";
          backend = "iwd";
        };
        ethernet.macAddress = "stable";
        dns = "systemd-resolved";
      };
      wireless.iwd.enable = true;
      dhcpcd.enable = false;
    };
    systemd.services.ModemManager.enable = false;
    services.resolved = {
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

    users.users.${config.cfg.core.username} = {
      extraGroups = ["networkmanager"];
    };
  };
}
