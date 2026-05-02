{
  inputs,
  self,
  lib,
  withSystem,
  ...
}: let
  # create tree of attributes assigned paths based on file tree
  # sourcing the attribute name from its stem
  mkTrees = loaders:
    lib.mapAttrs' (name: loader: {
      name = "${name}Tree";
      value = inputs.haumea.lib.load {
        src = ./. + "/${name}";
        inherit loader;
      };
    })
    loaders;

  dirs = mkTrees {
    modules = inputs.haumea.lib.loaders.path;
    hosts = inputs.haumea.lib.loaders.path;
    # please don't allow dotiles in the same diretory to share stems
    dotfiles = [(inputs.haumea.lib.matchers.always (_: path: path))];
  };

  inherit (dirs) dotfilesTree modulesTree hostsTree;

  # modules need to be in a flat list to be imported
  # since haumea already filtered for .nix files, every non-attribute set leaf is a module
  modulesList = lib.collect (x: !lib.isAttrs x) modulesTree;

  mkSystem = hostName: path: let
    system = "x86_64-linux";
  in
    withSystem system ({
      inputs',
      self',
      ...
    }:
      lib.nixosSystem {
        specialArgs = {
          inherit self self' inputs inputs';
        };
        modules = [
          self.nixosModules.default
          path
          {
            networking.hostName = hostName;
            nixpkgs.hostPlatform = lib.mkDefault system;
            system.stateVersion = lib.mkDefault "25.11";
          }
        ];
      });
in {
  flake.nixosModules =
    modulesTree
    // {
      default = {
        _module.args.dotfiles = dotfilesTree;
        imports = modulesList;
      };
    };

  flake.nixosConfigurations = lib.mapAttrs (name: path: mkSystem name path) (
    lib.filterAttrs (n: v: !lib.isAttrs v) hostsTree
  );
}
