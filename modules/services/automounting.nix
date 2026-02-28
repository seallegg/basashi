{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf getExe;
  cfg = config.cfg.services.automounting;
in {
  options.cfg.services.automounting.enable = mkEnableOption "autmomounting";
  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.udiskie];
    services.udisks2.enable = true;
    systemd.user.services.udiskie = {
      description = "udiskie daemon";
      after = ["udisks2.service" "graphical-session.target"];
      partOf = ["graphical-session.target"];
      serviceConfig.ExecStart = "${getExe pkgs.udiskie} --smart-tray";
    };
  };
}
