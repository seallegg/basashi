{ config, inputs, lib, ... }:
let
  inherit (lib.modules) mkAliasOptionModule;
  inherit (config.basashi.core) username;
in
{
  options.basashi.core = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "user";
      description = "Sets the username for the system.";
    };

    # declared here rather than in flake/bootstrapping.nix, which only consumes it,
    # so that modules reading it stay portable
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/${username}/basashi";
      description = "Where the config repo lives on this host.";
    };
  };

  imports =
    [ inputs.hjem.nixosModules.default (mkAliasOptionModule [ "hj" ] [ "hjem" "users" username ]) ];
  config = {
    users.users.${username} = {
      isNormalUser = true;
      initialPassword = "changeme";
      extraGroups = [ "wheel" "video" "input" ];
      uid = 1000;
    };
    hjem = {
      clobberByDefault = true;
      users.${username} = { enable = true; };
      extraModules = [ inputs.hjem-rum.hjemModules.default ];
    };
  };
}
