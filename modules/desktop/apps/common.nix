{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.cfg.desktop.environment;
in {
  config = mkIf cfg.niri.enable or cfg.plasma.enable {
    hj.packages = with pkgs; [
      kitty
      floorp-bin
      mpv
      zed-editor
      obsidian
      vesktop
      gimp
      libreoffice-qt-fresh
      zapzap
    ];
  };
}
