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
    services.resolved.enable = true;
    systemd.services.ModemManager.enable = false;

    users.users.${config.cfg.core.username} = {
      extraGroups = ["networkmanager"];
    };
  };
}
