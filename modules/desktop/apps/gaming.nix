{ config, inputs, lib, pkgs, ... }:
let
in {
  options.basashi.desktop.apps.gaming = { enable = lib.mkEnableOption "gaming"; };

  config = lib.mkIf config.basashi.desktop.apps.gaming.enable {
    programs.steam = {
      enable = true;
      package = pkgs.millennium-steam;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
    };

    programs.gamemode.enable = true;

    hj.packages = with pkgs; [
      mangohud
      protonup-qt

      (prismlauncher.override {
        additionalPrograms = [ ffmpeg ]; # required by some mods
        jdks = [ temurin-jre-bin-8 temurin-jre-bin-25 ];
      })
    ];
  };
}
