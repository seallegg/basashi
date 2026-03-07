{
  config,
  hostConfig,
  lib,
  ...
}: let
  inherit (lib) types;

  cfg = config.cfg.core.forceCompiledPkgs;
  flags =
    if hostConfig.arch != null
    then " -O3 -march=${hostConfig.arch} -mtune=${hostConfig.arch}" # mind the space
    else builtins.warn "forceCompiledPkgs: You may want to set this host's arch." " -O3";

  # fetches both env and top-level NIX_CFLAGS_COMPILE
  addFlags = pkg:
    pkg.overrideAttrs (
      old:
        if old ? env && old.env ? NIX_CFLAGS_COMPILE
        then {
          env =
            old.env
            // {
              NIX_CFLAGS_COMPILE = old.env.NIX_CFLAGS_COMPILE + flags;
            };
        }
        else {
          NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + flags;
        }
    );

  makeOverlay = pkgNames: prev:
    builtins.listToAttrs (
      map (name: {
        inherit name;
        value =
          if prev ? ${name}
          then addFlags prev.${name}
          else builtins.warn "forceCompiledPkgs: Package '${name}' not found in pkgs" prev.${name} or null;
      })
      (builtins.filter (name: prev ? ${name}) pkgNames)
    );
in {
  options.cfg.core.forceCompiledPkgs = {
    enable = lib.mkEnableOption "forced optimized compilation of selected packages";
    pkgs = lib.mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        List of packages to be compiled from source with agressive and architecture-specific optimization flags.
        Adding even one package may trigger compilation of a massive number of dependents.
        Expect very long build times and many failures.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev: makeOverlay cfg.pkgs prev)
    ];
  };
}
