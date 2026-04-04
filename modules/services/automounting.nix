{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cfg.services.automounting.enable = lib.mkEnableOption "autmomounting";
  config = lib.mkIf config.cfg.services.automounting.enable {
    environment.systemPackages = [pkgs.udiskie];
    services.udisks2.enable = true;
    systemd.user.services.udiskie = {
      description = "udiskie daemon";
      after = ["udisks2.service" "graphical-session.target"];
      partOf = ["graphical-session.target"];
      serviceConfig.ExecStart = "${pkgs.udiskie}/bin/udiskie --smart-tray";
    };
  };
}
