{ config, lib, pkgs, ... }: {
  options.basashi.desktop.environment.quickshell.enable = lib.mkEnableOption "quickshell";

  config = lib.mkIf config.basashi.desktop.environment.quickshell.enable {
    hj.packages = with pkgs; [ quickshell ];
  };
}
