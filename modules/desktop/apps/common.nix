{ config, inputs, lib, pkgs, ... }:
let cfg = config.basashi.desktop.environment;
in {
  config = lib.mkIf cfg.niri.enable or cfg.plasma.enable {
    hj.packages = with pkgs; [
      kitty
      inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
      mpv
      obsidian
      equibop
      gimp
      libreoffice-qt-fresh
      zapzap
      cider-2
    ];
    # god knows why this can´t be installed as a user package
    environment.systemPackages = with pkgs; [ obs-studio ];
  };
}
