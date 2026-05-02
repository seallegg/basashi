{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.basashi.core.hardware.monitors = mkOption {
    type = types.listOf (types.submodule {
      options = {
        name = mkOption {type = types.str;};
        res = mkOption {type = types.str;};
        pos = mkOption {
          type = types.submodule {
            options = {
              x = mkOption {type = types.int;};
              y = mkOption {type = types.int;};
            };
          };
          default = {
            x = 0;
            y = 0;
          };
        };
        scale = mkOption {
          type = types.float;
          default = 1.0;
        };
        VRR = mkOption {
          type = types.bool;
          default = false;
        };
      };
    });
    default = [];
  };

  config = {
    boot.kernelParams = map (m: "video=${m.name}:${m.res}") config.basashi.core.hardware.monitors;
  };
}
