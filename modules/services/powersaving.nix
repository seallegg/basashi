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
in {
  options.basashi.services.powersaving.enable = lib.mkEnableOption "power saving optimizations";

  config = mkIf cfg.enable {
    boot.kernelParams = [ "amd_pstate=active" ];

    services.auto-cpufreq.enable = true;
    services.auto-cpufreq.settings = {
      charger = {
        governor = "performance";
        energy_performance_preference = "performance";
      };
      battery = {
        governor = "powersave";
        energy_performance_preference = "power";
        turbo = "never";
      };
    };

    services.udev.extraRules = ''
      SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${powerStateChange} AC"
      SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${powerStateChange} BATTERY"
    '';

    networking.networkmanager.wifi.powersave = config.basashi.core.networking.networkmanager.enable;

    environment.systemPackages = with pkgs; [
      powertop # for monitoring only
      brightnessctl
    ];
  };
}
