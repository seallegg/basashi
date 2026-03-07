{
  lib,
  config,
  inputs,
  inputs',
  ...
}: let
  inherit (lib) mkOption types;
  inherit (lib.modules) mkAliasOptionModule;
  inherit (config.cfg.core) username;
in {
  options.cfg.core.username = mkOption {
    type = types.str;
    default = "user";
    description = "Sets the username for the system.";
  };
  imports = [
    inputs.hjem.nixosModules.default
    (mkAliasOptionModule ["hj"] ["hjem" "users" username])
  ];
  config = {
    users.users.${username} = {
      isNormalUser = true;
      initialPassword = "changeme";
      extraGroups = [
        "wheel"
        "video"
        "input"
      ];
      uid = 1000;
    };
    hjem = {
      linker = inputs'.hjem.packages.smfh;
      clobberByDefault = true;
      users.${username} = {
        enable = true;
      };
      extraModules = [inputs.hjem-rum.hjemModules.default];
    };
  };
}
