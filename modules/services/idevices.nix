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
    services.usbmuxd = {
      enable = true;
      #    package = pkgs.usbmuxd2;
    };
    environment.systemPackages = with pkgs; [
      libimobiledevice
      ifuse
      libplist
    ];
  };
}
