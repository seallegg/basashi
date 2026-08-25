{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf;
  cfg = config.basashi.services.powersaving;

  powerStateChange = pkgs.writeShellScript "power-state-change" ''
    state=$1
    case $state in
      AC)
        ${pkgs.brightnessctl}/bin/brightnessctl set 100%
        ${pkgs.brightnessctl}/bin/brightnessctl --device='*kbd_backlight' set 100%
        ;;
      BATTERY)
        ${pkgs.brightnessctl}/bin/brightnessctl set 30%
        ${pkgs.brightnessctl}/bin/brightnessctl --device='*kbd_backlight' set 0%
        ;;
    esac
  '';
in
{
  options.basashi.services.powersaving.enable = lib.mkEnableOption "power saving optimizations";

  config = mkIf cfg.enable {
    boot.kernelParams = [ "amd_pstate=active" ];

    services = {
      watt = {
        enable = true;
        settings.rule = [
          {
            name = "base";
            priority = 0;
            cpu = {
              governor.first-available-governor = [ "schedutil" "powersave" ];
              energy-performance-preference = {
                "if".is-energy-performance-preference-available = "balance_performance";
                "then" = "balance_performance";
              };
            };
          }
          {
            name = "ac";
            priority = 10;
            "if".not = "?discharging";
            cpu = {
              energy-performance-preference = {
                "if".is-energy-performance-preference-available = "performance";
                "then" = "performance";
              };
              turbo = {
                "if" = "?turbo-available";
                "then" = true;
              };
            };
            power.platform-profile = {
              "if".is-platform-profile-available = "balanced";
              "then" = "balanced";
            };
          }
          {
            name = "battery";
            priority = 20;
            "if" = "?discharging";
            cpu = {
              energy-performance-preference = {
                "if".is-energy-performance-preference-available = "power";
                "then" = "power";
              };
              turbo = {
                "if" = "?turbo-available";
                "then" = false;
              };
            };
            power.platform-profile = {
              "if".is-platform-profile-available = "low-power";
              "then" = "low-power";
            };
          }
        ];
      };
      udev.extraRules = ''
        SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${powerStateChange} AC"
        SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${powerStateChange} BATTERY"
      '';
    };

    networking.networkmanager.wifi.powersave = config.basashi.core.networking.networkmanager.enable;

    environment.systemPackages = with pkgs; [
      powertop # for monitoring only
      brightnessctl
    ];
  };
}
