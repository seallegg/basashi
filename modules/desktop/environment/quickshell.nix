{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cfg.desktop.environment.quickshell.enable = lib.mkEnableOption "quickshell";

  config = lib.mkIf config.cfg.desktop.environment.quickshell.enable {
    hj.packages = with pkgs; [
      quickshell
    ];
  };
}
