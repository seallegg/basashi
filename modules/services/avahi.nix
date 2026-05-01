{
  config,
  lib,
  ...
}: let
  cfg = config.basashi.services.avahi;
in {
  options.basashi.services.avahi = {
    enable = lib.mkEnableOption "Avahi mDNS/DNS-SD discovery";
  };

  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
        userServices = true;
      };
    };
  };
}
