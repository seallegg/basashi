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
      vesktop
      gimp
      libreoffice-qt-fresh
      zapzap
    ];
  };
}
