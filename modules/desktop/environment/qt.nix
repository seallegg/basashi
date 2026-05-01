{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.basashi.desktop.environment.niri.enable {
    nixpkgs.overlays = [inputs.qt6ct-kde.overlays.default];
    qt.style = "darkly";
    qt.platformTheme = "qt6ct";
    hj = {
      packages = with pkgs; [
        papirus-icon-theme
        darkly
        qt6Packages.qt6ct
      ];
      xdg.config.files = {
        "qt6ct/qt6ct.conf" = {
          generator = lib.generators.toINI {};
          value = {
            Appearance = {
              color_scheme_path = "~/.local/share/color-schemes/Darkly.colors";
              custom_palette = "true";
              icon_theme = "Papirus-Dark";
              standard_dialogs = "xdgdesktopportal";
              style = "Darkly";
            };
            Fonts = {
              fixed = ''"monospace,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"'';
              general = ''"sans-serif,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"'';
            };
          };
        };
        "darklyrc".text = ''
          [Common]
          CornerRadius=12
          ScrollBarTransient=true

          [Style]
          DolphinSidebarOpacity=85
          MenuBarOpacity=85
          MenuOpacity=80
          MnemonicsMode=MN_NEVER
          TabBarOpacity=85
          ToolBarOpacity=85
        '';
      };
      rum.desktops.niri.extraVariables.QT_QPA_PLATFORMTHEME = "qt6ct";
    };
  };
}
