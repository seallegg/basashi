{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.cfg.desktop.environment.niri;
in {
  config = mkIf cfg.enable {
    security.polkit.enable = true;
    systemd.user.services.mate-polkit = {
      enable = true;
      description = "Mate Polkit agent";
      after = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      unitConfig = {
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
