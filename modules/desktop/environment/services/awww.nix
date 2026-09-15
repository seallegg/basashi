{ config, lib, pkgs, ... }: {
  options.basashi.services.awww = { enable = lib.mkEnableOption "awww"; };

  config = lib.mkIf config.basashi.services.awww.enable {
    environment.systemPackages = [ pkgs.awww ];
    systemd.user.services.awww = {
      enable = true;
      description = "Wayland wallpaper daemon";
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
      # the daemon restores the cached wallpaper itself, by exec'ing `awww img`
      # out of PATH. without this it silently can't, and nothing gets drawn.
      path = [ pkgs.awww ];
      serviceConfig = {
        ExecStart = "${pkgs.awww}/bin/awww-daemon";
        Type = "simple";
        Restart = "on-failure";
      };
    };
  };
}
