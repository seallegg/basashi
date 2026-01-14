{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.cfg.desktop.environment;
in {
  config = mkIf cfg.niri.enable or cfg.plasma.enable {
    hj.packages = with pkgs; [
      kitty
      floorp-bin
      mpv
      zed-editor
      obsidian
      vesktop
      gimp
    ];
    xdg.mime.defaultApplications = {
      "inode/directory" = "org.kde.dolphin.desktop";
      "text/*" = "nvim.desktop";
      "image/*" = "org.kde.gwenview.desktop";
      "video/*" = "mpv.desktop";
      "audio/*" = "mpv.desktop";
    };
  };
}
