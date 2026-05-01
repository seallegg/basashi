{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkMerge mkOption types;
  cfg = config.basashi.services.networking;
in {
  options.basashi.services.networking = {
    staticIP = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = {
        eno1 = "192.168.1.100/24";
      };
      description = "Attribute set mapping specified interface names to static IP addresses.";
    };
    defaultGateway = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "192.168.1.1";
      description = "Default gateway address for the system.";
    };
    networkmanager = {
      enable = mkEnableOption "NetworkManager";
    };
    DoT.enable = mkEnableOption "DNS over TLS";
    mullvad.enable = mkEnableOption "Mullvad VPN";
  };

  imports = [inputs.mullvad-declarative.nixosModules.default];

  config = mkMerge [
    {
      networking = {
        interfaces =
          lib.mapAttrs (name: ip: {
            useDHCP = false;
            ipv4.addresses = [
              {
                address = builtins.head (lib.splitString "/" ip);
                prefixLength = lib.toInt (builtins.elemAt (lib.splitString "/" ip) 1);
              }
            ];
          })
          cfg.staticIP;
        defaultGateway = mkIf (cfg.defaultGateway != null) cfg.defaultGateway;

        dhcpcd.enable = false;
        wireless.iwd = {
          enable = true;
          settings.Network.EnableNetworkConfiguration = !cfg.networkmanager.enable;
        };
      };

      services.resolved = {
        enable = true;
        settings.Resolve = mkIf cfg.DoT.enable {
          DNS = [
            "45.90.28.0#bbf3e5.dns.nextdns.io"
            "2a07:a8c0::bbf3e5#.dns.nextdns.io"
            "45.90.30.0#bbf3e5.dns.nextdns.io"
            "2a07:a8c1::#bbf3e5.dns.nextdns.io"
          ];
          DNSOverTLS = "opportunistic";
        };
      };
    }

    (mkIf cfg.networkmanager.enable {
      networking.networkmanager = {
        enable = true;
        wifi.backend = "iwd";
        dns = "systemd-resolved";
      };
      users.users.${config.basashi.core.username}.extraGroups = ["networkmanager"];
      programs.nm-applet.enable = true;
      systemd.services.ModemManager.enable = false;
    })

    (mkIf cfg.mullvad.enable {
      services.mullvad-vpn-declarative = {
        enable = true;
        settings = {
          dns = {
            mode = "custom";
            customServers = [
              "2a07:a8c0::bb:f3e5"
              "2a07:a8c0::bb:f3e5"
            ];
          };
          multihop.enable = false;
          tunnel = {
            daita.enable = false;
            ipv6 = false; # It just does not work otherwise. I do not feel like figuring out why
          };
        };
      };
      nixpkgs.overlays = [inputs.mullvad-declarative.overlays.default];
    })
  ];
}
