{ config, lib, pkgs, ... }: {
  options.basashi.services.idevices.enable = lib.mkEnableOption "IOS device support";
  config = lib.mkIf config.basashi.services.idevices.enable {
    services.usbmuxd.enable = true;
    environment.systemPackages = with pkgs; [ libimobiledevice ifuse libplist ];
  };
}
