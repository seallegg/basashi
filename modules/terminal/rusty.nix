{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.basashi.terminal;
in {
  options.basashi.terminal.rusty.enable =
    mkEnableOption "modern, generally rust-based replacements for classic utilities";
  # in actuality, I just thought the name was cute

  config = mkIf cfg.rusty.enable {
    environment.systemPackages = with pkgs; [ bat fd ripgrep ripgrep-all eza xcp zoxide ];
    programs.fish = mkIf cfg.fish.enable {
      shellAliases = {
        rg = "rg --color=auto";
        rga = "rga --color=auto";
        find = "fd";
        ls = "eza --group-directories-first --hyperlink --icons=auto";
        tree = "eza --group-directories-first --hyperlink --tree --icons=auto";
        cp = "xcp";
      };
      shellAbbrs = {
        # abbreviations run on top of aliases, so this is a little neater
        la = "ls -a";
        ll = "ls --long --git --header";
        lla = "ls --long --git --header -a";
      };
    };
    basashi.internal.extraFishInit = mkIf cfg.fish.enable [''
      ${pkgs.zoxide}/bin/zoxide init fish --cmd cd | source
    ''];
  };
}
