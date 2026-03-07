{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cfg.services.swaync.enable = lib.mkEnableOption "swaync";
  config = lib.mkIf config.cfg.services.swaync.enable {
    environment.systemPackages = with pkgs; [
      swaynotificationcenter
    ];
    systemd.user.services.swaync = {
      enable = true;
      description = "Sway Notification Center";
      partOf = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];
      after = ["graphical-session.target"];
      unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
      serviceConfig = {
        ExecStart = "${pkgs.swaynotificationcenter}/bin/swaync";
        Type = "simple";
        Restart = "on-failure";
      };
    };
  };
}
