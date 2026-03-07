{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cfg.desktop.environment;
in {
  imports = [inputs.apple-fonts.nixosModules.default];
  config = lib.mkIf cfg.niri.enable or cfg.plasma.enable {
    fonts = {
      apple-fonts.enable = true;
      packages = with pkgs; [
        noto-fonts
        dejavu_fonts
        freefont_ttf
        gyre-fonts
        liberation_ttf
        unifont
        corefonts
        vista-fonts
        maple-mono.NF
      ];
      fontconfig = {
        defaultFonts = {
          sansSerif = ["SF Pro"];
          serif = ["New York"];
          monospace = ["Maple Mono NF"];
          emoji = ["Apple Color Emoji"];
        };
        antialias = true;
        hinting = {
          enable = true;
          autohint = true;
          style = "slight";
        };
        subpixel = {
          rgba = "rgb";
          lcdfilter = "default";
        };
      };
    };
  };
}
