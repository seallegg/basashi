{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkForce;
in {
  config = mkIf config.cfg.desktop.environment.niri.enable {
    xdg = {
      mime.defaultApplications = {
        "inode/directory" = "org.kde.dolphin.desktop";
        "text/*" = "nvim.desktop";
        "image/*" = "org.kde.gwenview.desktop";
        "video/*" = "mpv.desktop";
        "audio/*" = "mpv.desktop";
      };
      portal = {
        enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
          pkgs.kdePackages.xdg-desktop-portal-kde
          pkgs.xdg-desktop-portal-gnome
        ];
        config.niri.default = mkForce ["kde" "gtk" "gnome"];
        configPackages = [pkgs.niri];
      };
    };
  };
}
