# a recursive file-tree loader inspired by haumea
{ lib }:
let
  inherit (lib)
    hasPrefix
    head
    tail
    all
    stringToCharacters
    splitString
    foldl'
    concatLists
    mapAttrsToList
    isAttrs
    ;

  getStem = name: head (splitString "." name);
  # "but what if the directory starts with a dot?"
  # it's ignored. all hidden entries are.

  # little name filter to avoid quoted attribute names.
  isValidIdentifier =
    stem:
    let
      chars = stringToCharacters stem;
      # note: hyphenated names apparently don't play well with `with` expressions
      # I don't believe this matters for my use cases
      validFirst = c: (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") || c == "_";
      validRest = c: validFirst c || (c >= "0" && c <= "9") || c == "-" || c == "'";
    in
    stem != "" && validFirst (head chars) && all validRest (tail chars);

  mkSubtree = tree: list: {
    # originally i just checked for list and tree keys
    # but those names are too generic so here's a tag
    __loaderSubtree = true;
    inherit tree list;
  };
  isSubtree = v: isAttrs v && v.__loaderSubtree or false;

  load =
    {
      src,

      # called for each file entry, where type is the same as
      # builtins.readDir's values ("regular", "symlink", "unknown").
      # entries returning false are excluded.
      # e.g. `name: type: hasSuffix ".nix" name`
      # directories are always recursed into, use the _ or . prefixes to exclude them.
      fileFilter ? (name: type: true),

      # transforms file entries into a value, stored in the
      # repsective tree attributes and outputted raw for the list
      mapper ? (name: path: path),
    }:
    let
      contents = builtins.readDir src;
      resolveEntry =
        name: type:
        let
          path = src + "/${name}";
          stem = getStem name;
          ignored = hasPrefix "_" name || hasPrefix "." name || (!fileFilter name type && type != "directory");
        in
        if ignored then
          [ ] # ignore prefixed entries & filtered files
        else if !(isValidIdentifier stem) then
          throw "basashi loader error: '${stem}' (from '${toString path}') is not a valid identifier"
        else if type == "directory" then
          let # recursively load subdirs
            subtree = load {
              inherit fileFilter mapper;
              src = path;
            };
          in
          if subtree.tree == { } then
            [ ] # ignore empty directories (after recursion, so please avoid them)
          else
            [
              {
                name = stem;
                value = mkSubtree subtree.tree subtree.list;
              }
            ]
        else
          [
            {
              name = stem;
              value = mapper name path;
            }
          ];

      rawEntries = concatLists (mapAttrsToList resolveEntry contents);

      mergeEntry = acc: e: {
        tree =
          if acc.tree ? ${e.name} then # check if previous tree contains the current entry
            throw "basashi loader error: Name collision on '${e.name}' in '${toString src}'"
          else
            acc.tree
            // {
              ${e.name} = if isSubtree e.value then e.value.tree else e.value;
            };
        # as a result of this, lists show entries alphabetically a subtree is found,
        # at which point it inserts the list of its own entries alphabetically.
        # this could be relevant in ordering-sensitive uses
        list = acc.list ++ (if isSubtree e.value then e.value.list else [ e.value ]);
      };
    in
    foldl' mergeEntry {
      tree = { };
      list = [ ];
    } rawEntries;
in
load
