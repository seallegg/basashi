{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cfg.services.swww = {
    enable = lib.mkEnableOption "swww";
  };

  config = lib.mkIf config.cfg.services.swww.enable {
    environment.systemPackages = with pkgs; [swww];
    systemd.user.services.swww = {
      enable = true;
      description = "Wayland wallpaper daemon";
      partOf = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];
      after = ["graphical-session.target"];
      unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
      serviceConfig = {
        ExecStart = "${pkgs.swww}/bin/swww-daemon";
        ExecStartPost = "${pkgs.swww}/bin/swww restore";
        Type = "simple";
        Restart = "on-failure";
      };
    };
  };
}
