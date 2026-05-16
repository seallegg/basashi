{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.basashi.desktop.environment;
in {
  imports = [inputs.apple-fonts.nixosModules.default];
  config = lib.mkIf cfg.niri.enable or cfg.plasma.enable {
    fonts = {
      apple-fonts.enable = true;
      packages = with pkgs; [
        corefonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        vista-fonts
        maple-mono.NF
      ];
      fontconfig = {
        defaultFonts = {
          sansSerif = ["SF Pro Text"];
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
        localConf = ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
          <fontconfig>

            <!-- Swap sans-serif (SF Pro Text) to SF Pro Display for large sizes -->
            <match target="pattern">
              <test name="family" qual="any">
                <string>sans-serif</string>
              </test>
              <test name="size" compare="more_eq">
                <double>20</double>
              </test>
              <edit name="family" mode="assign" binding="same">
                <string>SF Pro Display</string>
              </edit>
            </match>

            <!-- Same for large pixelsizes -->
            <match target="pattern">
              <test name="family" qual="any">
                <string>sans-serif</string>
              </test>
              <test name="pixelsize" compare="more_eq">
                <double>26</double>
              </test>
              <edit name="family" mode="assign" binding="same">
                <string>SF Pro Display</string>
              </edit>
            </match>
          </fontconfig>
        '';
      };
    };
  };
}
