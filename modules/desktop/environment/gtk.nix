{ config, lib, pkgs, ... }: {
  config = lib.mkIf config.basashi.desktop.environment.niri.enable {
    programs.dconf.profiles.user.databases = [{
      lockAll = true;
      settings = {
        "org/gnome/desktop/interface" = {
          gtk-theme = "Colloid-Dark";
          icon-theme = "Papirus-Dark";
          font-name = "Sans 11";
          document-font-name = "Sans 11";
          monospace-font-name = "Monospace 11";
          color-scheme = "prefer-dark";
          cursor-theme = "Posy_Cursor_Black";
          cursor-size = "32";
          gtk-enable-primary-paste = "false";
        };
        "org/gnome/desktop/wm/preferences".button-layout = ":";
        "org.gnome.desktop.sound".theme-name = "ocean";
      };
    }];
    environment.sessionVariables.GTK_THEME = "Colloid-Dark";
    hj = {
      packages = with pkgs; [
        papirus-icon-theme
        colloid-gtk-theme
        posy-cursors
        kdePackages.ocean-sound-theme
      ];
      rum = {
        misc.gtk = {
          enable = true;
          settings = {
            theme-name = "Colloid-Dark";
            icon-theme-name = "Papirus-Dark";
            font-name = "Sans 11";
            application-prefer-dark-theme = "true";
            cursor-theme-name = "Posy_Cursor_Black";
            cursor-theme-size = "32";
          };
        };
      };
    };
  };
}
