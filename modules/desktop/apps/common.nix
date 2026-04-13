{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cfg.desktop.environment;
in {
  config = lib.mkIf cfg.niri.enable or cfg.plasma.enable {
    hj.packages = with pkgs; [
      kitty
      floorp-bin
      mpv
      obsidian
      equibop
      gimp
      libreoffice-qt-fresh
      zapzap
      cider-2
    ];
    environment.systemPackages = with pkgs; [
      obs-studio # god knows why this can´t be installed as a user package
    ];
  };
}
