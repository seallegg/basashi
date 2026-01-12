{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
in {
  options.cfg.desktop.apps.gaming = {
    enable = mkEnableOption "gaming";
  };

  config = mkIf config.cfg.desktop.apps.gaming.enable {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
    };

    programs.gamemode.enable = true;

    hj.packages = with pkgs; [
      mangohud
      protonup-qt
      apotris
      lutris

      (prismlauncher.override {
        additionalPrograms = [ffmpeg]; # required by some mods
        jdks = [
          temurin-jre-bin-8
          temurin-jre-bin-17
          temurin-jre-bin-25
        ];
      })
    ];
  };
}
