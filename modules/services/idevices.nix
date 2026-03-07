{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cfg.services.idevices.enable = lib.mkEnableOption "IOS device support";
  config = lib.mkIf config.cfg.services.idevices.enable {
    services.usbmuxd.enable = true;
    environment.systemPackages = with pkgs; [
      libimobiledevice
      ifuse
      libplist
    ];
  };
}
