{ config, lib, pkgs, ... }: {
  options.basashi = {
    terminal.fish.enable = lib.mkEnableOption "the fish shell";
    # why something like this isn't built in to nixpkgs is beyond me, but whatever
    internal.extraFishInit = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra code to be included at the end of programs.fish.shellInit.";
    };
  };

  config = lib.mkIf (config.basashi.terminal.fish.enable) {
    users.users.${config.basashi.core.username}.shell = lib.mkForce pkgs.fish;

    environment.systemPackages = with pkgs; [
      fzf
      fishPlugins.fzf-fish
      grc
      fishPlugins.grc
      fishPlugins.plugin-sudope
      fishPlugins.sponge
      fishPlugins.done
    ];
    programs.fish = {
      enable = true;
      # bash translation layer written in go, faster than the original which is written in bash
      useBabelfish = true;
      shellAbbrs = {
        ns = "nh os switch";
        nsu = "nh os switch -u";
        nb = "nh os boot";
        nbu = "nh os boot -u";
      };
      shellAliases = { up = "../"; };

      shellInit = lib.concatStringsSep "\n" config.basashi.internal.extraFishInit + ''
        set fish_greeting
        if test "$TERM" != "linux"
          set -gx SUDO_PROMPT \e'[1;7m Password '\e'[0m '\n
        end
        ${pkgs.fzf}/bin/fzf --fish | source
      '';
    };

    # vm layout helper + host-name completion; only where we actually do vm work
    hj.xdg.config.files = lib.mkIf config.basashi.core.virtualization.libvirt.enable {
      "fish/functions/dvm.fish".text = ''
        function dvm --description 'boot a host disko layout in a throwaway vm'
            if test -z "$argv[1]"
                echo "usage: dvm <host>" >&2
                return 2
            end
            nix run -L ".#nixosConfigurations.$argv[1].config.system.build.vmWithDisko"
        end
      '';
      "fish/completions/dvm.fish".text = ''
        # host names straight from the flake (eval is the source of truth)
        function __dvm_hosts
            nix eval --raw \
                --apply 'cfgs: builtins.concatStringsSep "\n" (builtins.attrNames cfgs)' \
                .#nixosConfigurations 2>/dev/null
        end

        # only the first arg is a host; -f suppresses file completion
        complete -c dvm -f -n 'test (count (commandline -opc)) -eq 1' -a '(__dvm_hosts)'
      '';
    };
  };
}
