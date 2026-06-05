{ config, dotfiles, lib, pkgs, ... }: {
  options.basashi.terminal.ohMyPosh.enable = lib.mkEnableOption "oh-my-posh prompt";
  config = lib.mkIf config.basashi.terminal.ohMyPosh.enable {
    programs.fish.promptInit = ''
      if test "$TERM" != "linux"
        ${pkgs.oh-my-posh}/bin/oh-my-posh init fish --config ~/.config/oh-my-posh/prompt.toml | source
      end
    '';
    basashi.internal.extraFishInit = [''
      function rerender_on_dir_change --on-variable PWD
        omp_repaint_prompt
      end
    ''];
    hj.xdg.config.files."oh-my-posh/prompt.toml".text = dotfiles.ohmyposh.prompt;
  };
}
