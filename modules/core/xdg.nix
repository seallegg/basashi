{ config, inputs, lib, pkgs, ... }: {
  imports = [ inputs.nixdg-ninja.nixosModules.nixdg-ninja ];

  config = {
    programs.nixdg-ninja.enable = true;

    xdg = {
      mime.defaultApplications = {
        "inode/directory" = "org.kde.dolphin.desktop";
        "text/*" = "dev.zed.Zed.desktop";
        "image/*" = "org.kde.gwenview.desktop";
        "video/*" = "mpv.desktop";
        "audio/*" = "mpv.desktop";
        "application/pdf" = "org.kde.okular.desktop";
      };
      portal = {
        enable = true;
        extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
        config = {
          common.default = [ "kde" ];
          # force kde for everything except what has to be gnome
          niri = lib.mkIf config.programs.niri.enable (lib.mkForce {
            default = [ "kde" ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
            "org.freedesktop.impl.portal.RemoteDesktop" = [ "gnome" ];
            "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
          });
        };
      };
    };
  };
}
