{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.nixdg-ninja.nixosModules.nixdg-ninja];

  config = {
    programs.nixdg-ninja.enable = true;

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
          pkgs.kdePackages.xdg-desktop-portal-kde
          pkgs.xdg-desktop-portal-gtk
        ];
        config.common.default = ["kde"];
      };
    };
  };
}
