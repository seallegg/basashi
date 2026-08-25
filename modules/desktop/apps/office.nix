{ config, lib, pkgs, ... }: {
  options.basashi.desktop.apps.office.enable =
    lib.mkEnableOption "office and note taking apps";

  config = lib.mkIf config.basashi.desktop.apps.office.enable {
    hj.packages = with pkgs; [ libreoffice-qt-stable obsidian ];
  };
}
