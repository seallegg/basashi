{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf optional;
  cfg = config.basashi.desktop.apps.gaming;
  anyEnabled = cfg.steam.enable || cfg.steam.ckan.enable
    || cfg.minecraft.enable;
in
{
  options.basashi.desktop.apps.gaming = {
    steam.enable = mkEnableOption "Steam";
    steam.ckan.enable = mkEnableOption "KSP modding helper CKAN";

    minecraft.enable = mkEnableOption "Prism Launcher";
  };

  config = mkIf anyEnabled {
    programs.steam = mkIf cfg.steam.enable {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    programs.gamemode.enable = true;

    hj.packages = with pkgs;
      [ mangohud ] ++ optional cfg.steam.ckan.enable ckan
      ++ optional cfg.minecraft.enable (prismlauncher.override {
        additionalPrograms = [ ffmpeg ]; # required by some mods
        jdks = [ temurin-jre-bin-8 temurin-jre-bin-25 ];
      });
  };
}
