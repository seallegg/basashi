{ config, lib, ... }:
let cfg = config.basashi.services.avahi;
in {
  options.basashi.services.avahi = { enable = lib.mkEnableOption "Avahi mDNS/DNS-SD discovery"; };

  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
        userServices = true;
      };
      extraServiceFiles = lib.mkIf config.services.samba.enable {
        smb = ''
          <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
          <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
          <service-group>
            <name replace-wildcards="yes">%h</name>
            <service>
              <type>_smb._tcp</type>
              <port>445</port>
            </service>
            <service>
              <type>_device-info._tcp</type>
              <port>0</port>
              <txt-record>model=MacSamba</txt-record>
            </service>
          </service-group>
        '';
      };
    };
  };
}
