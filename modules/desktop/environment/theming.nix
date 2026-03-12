{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.cfg.desktop.environment.niri.enable {
    nixpkgs.overlays = [inputs.qt6ct-kde.overlays.default];

    programs.dconf.profiles.user.databases = [
      {
        lockAll = true;
        settings = {
          "org/gnome/desktop/interface" = {
            gtk-theme = "Colloid-Dark";
            icon-theme = "Papirus-Dark";
            font-name = "Sans Regular 12";
            document-font-name = "Sans Regular 12";
            monospace-font-name = "Monospace Regular 12";
            color-scheme = "prefer-dark";
            gtk-enable-primary-paste = false;
          };
          "org/gnome/desktop/wm/preferences".button-layout = ":";
        };
      }
    ];
    hj = {
      packages = with pkgs; [
        papirus-icon-theme
        colloid-gtk-theme
        vimix-cursors
        qt6Packages.qt6ct
        qt6Packages.qtstyleplugin-kvantum
      ];
      xdg.config.files."qt6ct/qt6ct.conf" = {
        generator = lib.generators.toINI {};
        value = {
          Appearance = {
            icon_theme = "Papirus-Dark";
            standard_dialogs = "xdgdesktopportal";
            style = "kvantum-dark";
          };
          Fonts = {
            fixed = ''"monospace,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"'';
            general = ''"sans-serif,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"'';
          };
        };
      };
      rum.desktops.niri.extraVariables = {
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_QPA_PLATFORMTHEME = "qt6ct";
        GTK_THEME = "Colloid-Dark";
      };
    };
  };
}
