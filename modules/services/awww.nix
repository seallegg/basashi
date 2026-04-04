{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cfg.services.awww = {
    enable = lib.mkEnableOption "awww";
  };

  config = lib.mkIf config.cfg.services.awww.enable {
    environment.systemPackages = [pkgs.awww];
    systemd.user.services.awww = {
      enable = true;
      description = "Wayland wallpaper daemon";
      partOf = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];
      after = ["graphical-session.target"];
      unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
      serviceConfig = {
        ExecStart = "${pkgs.awww}/bin/awww-daemon";
        ExecStartPost = "${pkgs.awww}/bin/awww restore";
        Type = "simple";
        Restart = "on-failure";
      };
    };
  };
}
