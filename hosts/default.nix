{
  inputs,
  lib,
  pins,
  self,
  withSystem,
  ...
}: let
  inherit (builtins) attrNames readDir;

  # Filter readDir to only include directories
  dirs = lib.filterAttrs (_: type: type == "directory") (readDir ./.);

  mkSystem = hostName: let
    hostConfig = import ./${hostName}/host-config.nix;
    system = hostConfig.system or "x86_64-linux"; # used for pre-selecting platforms using flake-parts
    arch = hostConfig.arch or null; # for optional tuning
    dotfiles = self + "/dotfiles";
  in
    withSystem system ({
      inputs',
      self',
      ...
    }:
      lib.nixosSystem {
        specialArgs = {
          inherit self self' inputs inputs' hostName pins dotfiles;
        };
        modules = [
          self.nixosModules.default # ${self}/modules directory as a nixosModule
          ./host-options.nix

          ./${hostName}
          {
            nixpkgs.hostPlatform = system;
            nix.settings.system-features =
              [
                "benchmark"
                "big-parallel"
                "kvm"
                "nixos-test"
              ]
              ++ (lib.lists.optional (arch != null) "gccarch-${arch}");

            cfg.hardware.monitors = hostConfig.monitors or [];
            cfg.hardware.arch = arch;
            cfg.hardware.system = system;
          }
        ];
      });
in {
  flake.nixosConfigurations = lib.genAttrs (attrNames dirs) mkSystem;
}
