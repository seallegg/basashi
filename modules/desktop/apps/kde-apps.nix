{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cfg.desktop.environment;
in {
  config = lib.mkIf cfg.niri.enable or cfg.plasma.enable {
    environment = {
      systemPackages = with pkgs; [
        kdePackages.qtsvg
        kdePackages.kio
        kdePackages.kio-fuse
        kdePackages.kio-admin
        kdePackages.kio-extras
        kdePackages.dolphin-plugins
      ];
      # Fix dolphin file associations. How hideous
      etc."xdg/menus/applications.menu".source = "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
    };
    hj = {
      packages = with pkgs; [
        kdePackages.dolphin
        kdePackages.gwenview
        kdePackages.ark
        kdePackages.filelight
        kdePackages.ktorrent
      ];
      xdg.config.files."kdeglobals" = {
        generator = lib.generators.toINI {};
        value = {
          General = {
            TerminalApplication = "kitty";
          };
          Icons.Theme = "papirus-dark";
        };
      };
    };
  };
}
