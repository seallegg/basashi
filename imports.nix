{inputs}: let
  inherit (inputs.nixpkgs) lib;
  inherit (inputs.self) outputs;
  inherit (lib) count hasPrefix hasSuffix isAttrs mkDefault;

  # a recursive file-tree loader inspired by haumea
  load = {
    src,
    fileFilter ? (name: type: true),
    mapper ? (name: path: path),
  }: let
    contents = builtins.readDir src;

    # extract the first part of the name (stem) for attribute naming
    getStem = name: type:
      if type == "directory"
      then name
      else lib.head (lib.splitString "." name);

    resolveEntry = name: type: let
      path = src + "/${name}";
      stem = getStem name type;
      isIgnored = hasPrefix "_" name || hasPrefix "." name; # skip hidden and private files
      hasMultipleDots = count (c: c == ".") (lib.stringToCharacters name) > 1;
    in
      if isIgnored
      then []
      else if type == "directory" # recursively load subdirectories
      then let
        subtree = load {
          inherit fileFilter mapper;
          src = path;
        };
      in
        if subtree == {}
        then []
        else [
          {
            name = stem;
            value = subtree;
          }
        ]
      else if fileFilter name type
      then
        if hasMultipleDots
        then throw "basashi Loader Error: File '${path}' has multiple dots in its name. This is forbidden to prevent quoted attribute names."
        else [
          {
            name = stem;
            value = mapper name path;
          }
        ]
      else [];

    rawEntries = lib.concatLists (lib.mapAttrsToList resolveEntry contents);

    mergeEntry = acc: e:
      if acc.tree ? ${e.name}
      then throw "Basashi Loader Error: Name collision on '${e.name}' in '${toString src}'"
      else let
        isSubtree = isAttrs e.value && e.value ? tree && e.value ? list;
      in {
        tree =
          acc.tree
          // {
            ${e.name} =
              if isSubtree
              then e.value.tree
              else e.value;
          };
        list =
          acc.list
          ++ (
            if isSubtree
            then e.value.list
            else [e.value]
          );
      };
  in
    # generate a tree of attributes with directories and a list of values with only leaves
    lib.foldl' mergeEntry {
      tree = {};
      list = [];
    }
    rawEntries;

  modules = load {
    src = ./. + "/modules";
    fileFilter = name: type: hasSuffix ".nix" name;
  };

  hosts = load {
    src = ./. + "/hosts";
    fileFilter = name: type: hasSuffix ".nix" name;
  };

  dotfiles = load {
    src = ./. + "/dotfiles";
    mapper = name: path: builtins.readFile path;
  };

  mkSystem = hostName: path:
    lib.nixosSystem {
      specialArgs = {
        inherit (inputs) self;
        inherit inputs;
        modules = outputs.nixosModules;
      };
      modules = [
        outputs.nixosModules.default
        path
        {
          networking.hostName = mkDefault hostName;
          nixpkgs.hostPlatform = mkDefault "x86_64-linux";
          system.stateVersion = mkDefault "25.11";
        }
      ];
    };
in {
  nixosModules =
    modules.tree
    // {
      default = {
        imports = modules.list;
        _module.args.dotfiles = dotfiles.tree;
      };
    };
  nixosConfigurations = lib.mapAttrs (name: path: mkSystem name path) (
    lib.filterAttrs (n: v: !isAttrs v) hosts.tree
  );
}
