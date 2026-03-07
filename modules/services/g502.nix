{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cfg.services.g502.enable = lib.mkEnableOption "g502";
  config = lib.mkIf config.cfg.services.g502.enable {
    environment.systemPackages = with pkgs; [
      solaar
      input-remapper
      usbutils
    ];
  };
}
