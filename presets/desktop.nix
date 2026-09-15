# the default desktop bundle
{ pkgs, ... }:
{
  basashi = {
    core = {
      networking = {
        DoT.enable = true;
        networkmanager.enable = true;
      };
      swap = {
        file.enable = true;
        zram.enable = true;
      };
    };

    desktop = {
      apps = {
        browser.enable = true;
        chat.enable = true;
        kdeApps.enable = true;
        kitty.enable = true;
        media.enable = true;
        office.enable = true;
        zed.enable = true;
      };
      environment = {
        fonts.enable = true;
        matugen.enable = true;
        niri.enable = true;
        rofi.enable = true;
        xdg.enable = true;
      };
    };

    services = {
      automounting.enable = true;
      awww.enable = true;
      compat.enable = true;
      pipewire.enable = true;
      plymouth.enable = true;
      polkit.enable = true;
      printing.enable = true;
      sddm.enable = true;
      swaync.enable = true;
    };

    terminal.agents.enable = true;
  };

  environment.systemPackages = [ pkgs.micro-full ]; # clipboard support
}
