{
  inputs,
  self,
  lib,
  ...
}: let
  # create tree of attributes assigned paths based on file tree
  modulePathTree = inputs.haumea.lib.load {
    src = ./.;
    loader = inputs.haumea.lib.loaders.path;
  };

  # turns tree into list of module paths
  # how ba-a-a-ad can i be?
  treeFlattener = attrs:
    lib.concatLists (lib.mapAttrsToList (
        name: value:
          if lib.isAttrs value # if attribute is a directory
          then treeFlattener value
          else if
            lib.hasSuffix ".nix" (toString value) # if it's a module
            && (baseNameOf value != "default.nix") # but not this file
          then [value] # pass it along
          else []
      )
      attrs);

  modulePathList = treeFlattener modulePathTree;
in {
  flake.nixosModules =
    modulePathTree # so they can be referenced like: self.nixosModules.desktop.environment.niri
    // {
      default = {
        imports = modulePathList; # actually import them
      };
    };
}
