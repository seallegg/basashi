{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.cfg.desktop.environment;
in {
  config = mkIf cfg.niri.enable or cfg.plasma.enable {
    environment.systemPackages = with pkgs; [
      kdePackages.qtsvg
      kdePackages.kio
      kdePackages.kio-fuse
      kdePackages.kio-admin
      kdePackages.kio-extras
      kdePackages.dolphin-plugins
    ];
    hj.packages = with pkgs; [
      kdePackages.dolphin
      kdePackages.gwenview
      kdePackages.ark
      kdePackages.filelight
      kdePackages.ktorrent
    ];
  };
}
