{ config, lib, pkgs, ... }:
let arch = if config.basashi.core.hardware.cpu.arch == "znver4" then "x86_64_v4" else "x86_64_v3";
in {
  options.basashi.desktop.apps.gaming = { enable = lib.mkEnableOption "gaming"; };

  config = lib.mkIf config.basashi.desktop.apps.gaming.enable {
    programs.steam = {
      enable = true;
      package = pkgs.millennium-steam;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      extraCompatPackages = [ pkgs.proton-ge-custom pkgs."proton-cachyos_${arch}" ];
    };

    programs.gamemode.enable = true;

    hj.packages = with pkgs; [
      mangohud
      ckan

      (prismlauncher.override {
        additionalPrograms = [ ffmpeg ]; # required by some mods
        jdks = [ temurin-jre-bin-8 temurin-jre-bin-25 ];
      })
    ];
  };
}
