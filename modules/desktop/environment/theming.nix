{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.cfg.desktop.environment;
in {
  config = mkIf cfg.niri.enable {
    nixpkgs.overlays = [inputs.qt6ct-kde.overlays.default];

    hj = {
      packages = with pkgs; [
        papirus-icon-theme
        colloid-gtk-theme
        vimix-cursors
        kdePackages.breeze
        qt6Packages.qt6ct
        qt6Packages.qtstyleplugin-kvantum
      ];
      rum.misc.gtk = {
        enable = true;
        settings = {
          theme-name = "Colloid-Dark";
          icon-theme-name = "Papirus-Dark";
          font-name = "Sans 12";
          application-prefer-dark-theme = "1";
          enable-primary-paste = false;
        };
      };
      xdg.config.files."qt6ct/qt6ct.conf" = {
        generator = lib.generators.toINI {};
        value = {
          Appearance = {
            custom_palette = true;
            color_scheme_path = "~/.config/qt6ct/colors/darker.conf";
            icon_theme = "Papirus-Dark";
            standard_dialogs = "xdgdesktopportal";
            style = "kvantum-dark";
          };
          Fonts = {
            fixed = ''"monospace,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"'';
            general = ''"Sans Serif,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"'';
          };
        };
      };
      rum.desktops.niri.extraVariables = {
        QT_QPA_PLATFORMTHEME = "qt6ct";
        GTK_THEME = "Colloid-Dark";
      };
    };
  };
}
