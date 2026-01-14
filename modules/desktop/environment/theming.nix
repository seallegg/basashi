{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.cfg.desktop.environment;
in {
  config = mkIf cfg.niri.enable or cfg.plasma.enable {
    hj = {
      packages = with pkgs; [
        papirus-icon-theme
        colloid-gtk-theme
        kdePackages.breeze
        qt6Packages.qt6ct
        qt6Packages.qtstyleplugin-kvantum
      ];
      rum.misc.gtk = {
        enable = true;
        settings = {
          application-prefer-dark-theme = true;
          icon-theme-name = "Papirus-Dark";
          font-name = "Sans 11";
          theme-name = "Colloid-Dark";
        };
      };
      xdg.config.files."qt6ct/qt6ct.conf" = {
        generator = lib.generators.toINI {};
        value = {
          Appearance = {
            custom_palette = true;
            color_scheme_path = "/home/seal/.config/qt6ct/colors/darker.conf";
            icon_theme = "Papirus-Dark";
            standard_dialogs = "xdgdesktopportal";
            style = "kvantum-dark";
          };
          Fonts = {
            fixed = ''"monospace,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"'';
            general = ''"sans-serif,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"'';
          };
        };
      };
      environment = {
        sessionVariables = {
          QT_QPA_PLATFORMTHEME = "qt6ct";
          GTK_THEME = "Colloid-Dark";
        };
      };
    };
  };
}
