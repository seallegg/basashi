{ config, lib, pkgs, ... }:
let inherit (lib) mkOption types;
in {
  options.basashi.terminal.git = {
    name = mkOption {
      type = types.str;
      default = "";
      description = "Username for git.";
    };
    email = mkOption {
      type = types.str;
      default = "";
      description = "Email address for git.";
    };
  };
  config = {
    programs.git = {
      enable = true;
      config = {
        user = { inherit (config.basashi.terminal.git) name email; };
        url."https://github.com/".InsteadOf = [ "github:" "gh" ];
        init.defaultBranch = "main";
      };
    };
    hj.packages = [ pkgs.gh ];
  };
}
