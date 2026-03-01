{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.cfg.core.git;
in {
  options.cfg.core.git = {
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
        user = {
          inherit (cfg) name email;
        };
        url."https://github.com/".InsteadOf = ["github:" "gh"];
        init.defaultBranch = "main";
      };
    };
    hj.packages = [pkgs.gh];
  };
}
