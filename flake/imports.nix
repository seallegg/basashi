# stuff that goes into a host
{ inputs, lib }:
let
  inherit (lib) mkOption types;

  specialArgs = { inherit inputs; inherit (inputs) self; };

  load = import ./loader.nix { inherit lib; };

  presetFiles = (load { src = ../presets; }).tree;

  # presets get applied at priority 900, which beats defaults but loses to anything the host sets by hand
  # a preset cannot call a preset, hosts have to name all of them
  # lists and derivations would be dropped whole if we set their priority, so we don't
  prioritize = value:
    if builtins.isList value || lib.isDerivation value || value ? _type then
      value
    else if builtins.isAttrs value then
      builtins.mapAttrs (_: prioritize) value
    else
      lib.mkOverride 900 value;

  wrap = path:
    let raw = import path;
    in
    if !(lib.isFunction raw) then
      { config = prioritize raw; }
    else
    # injects the formals (e.g. config, lib, pkgs)
      lib.setFunctionArgs (args: { config = prioritize (raw args); })
        (builtins.functionArgs raw);

  presetOption = {
    # this single option makes this file significantly more convoluted
    options.basashi.presets = mkOption {
      type = types.listOf (types.enum (builtins.attrNames presetFiles));
      default = [ ];
      example = [ "desktop" "terminal" ];
      description = "Preset bundles applied to this host, by filename in `presets/`.";
    };
  };

  # imports can't access config, so the host file gets evaluated "twice" (it's reused later):
  # once against a stub that only knows about the presets and once for real
  namesFor = path: (lib.evalModules {
    inherit specialArgs;
    modules = [
      path
      presetOption
      {
        _module.check = false;
      }
    ];
  }).config.basashi.presets;
in
{
  inherit specialArgs;

  globals = import ./globals.nix { inherit inputs; };
  modules = load { src = ../modules; };
  dotfiles = load {
    src = ../dotfiles;
    fileFilter = name: type: true;
    mapper = name: path: builtins.readFile path;
  };

  presets = {
    # the second eval
    option = presetOption;
    modulesFor = path: map (name: wrap presetFiles.${name}) (namesFor path);
  };
}
