{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.cfg.services.idevices;
in {
  options.cfg.services.idevices.enable = mkEnableOption "IOS device support";
  config = mkIf cfg.enable {
    services.usbmuxd.enable = true;
    environment.systemPackages = with pkgs; [
      libimobiledevice
      ifuse
      libplist
    ];
  };
}
