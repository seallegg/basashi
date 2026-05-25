{ config, inputs, lib, ... }: {
  options.basashi.services.mullvad.enable = lib.mkEnableOption "Mullvad VPN";

  imports = [ inputs.mullvad-declarative.nixosModules.default ];

  config = lib.mkIf config.basashi.services.mullvad.enable {
    services.mullvad-vpn-declarative = {
      enable = true;
      settings = {
        dns = {
          mode = "custom";
          customServers = [ "2a07:a8c0::bb:f3e5" "2a07:a8c0::bb:f3e5" ];
        };
        multihop.enable = false;
        tunnel = {
          daita.enable = false;
          ipv6 = false;
        };
      };
    };
  };
}
