{
  description = "basashi, a synaptic NixOS configuration";

  # inputs now live in ./.tack/pins.toml where they are lazily fetched
  outputs = { self, ... }@args:
    let pins = (import ./.tack) { overrides = args.tackOverrides or { }; };
    in import ./imports.nix { inputs = pins // { inherit self; }; };
}
