{ config, lib, pkgs, ... }: {
  options.basashi.desktop.hyprlock.enable = lib.mkEnableOption "hyprlock";
  config = lib.mkIf config.basashi.desktop.hyprlock.enable {
    hj.userPackages = [ pkgs.hyprlock pkgs.hypridle ];
  };
}
