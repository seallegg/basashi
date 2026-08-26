{ config, lib, pkgs, ... }:
let def = lib.mkOverride 900;
in {
  options.basashi.presets.desktop = lib.mkEnableOption "the default desktop bundle";

  config = lib.mkIf config.basashi.presets.desktop {
    basashi = {
      presets = {
        locale = def true;
        terminal = def true;
      };

      core = {
        networking = {
          DoT.enable = def true;
          networkmanager.enable = def true;
        };
        swap = {
          file.enable = def true;
          zram.enable = def true;
        };
      };

      desktop = {
        apps = {
          browser.enable = def true;
          chat.enable = def true;
          kdeApps.enable = def true;
          kitty.enable = def true;
          media.enable = def true;
          office.enable = def true;
          zed.enable = def true;
        };
        environment = {
          fonts.enable = def true;
          matugen.enable = def true;
          niri.enable = def true;
          rofi.enable = def true;
          xdg.enable = def true;
        };
      };

      services = {
        automounting.enable = def true;
        awww.enable = def true;
        compat.enable = def true;
        pipewire.enable = def true;
        plymouth.enable = def true;
        polkit.enable = def true;
        printing.enable = def true;
        sddm.enable = def true;
        swaync.enable = def true;
      };

      terminal.agents.enable = def true;
    };
    environment.systemPackages = [ pkgs.micro-full ]; # clipboard support
  };
}
