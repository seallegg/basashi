{
  pkgs,
  dotfiles,
  config,
  ...
}: {
  environment = {
    systemPackages = with pkgs; [
      zinit
      oh-my-posh
      fzf
      zoxide
      bat
    ];
    sessionVariables.ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
  };
  users.users.${config.cfg.core.username}.shell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    histFile = "$ZDOTDIR/zsh_history";
    histSize = 50000;

    setOptions = [
      "EXTENDED_HISTORY"
      "APPEND_HISTORY"
      "SHARE_HISTORY"
      "HIST_IGNORE_DUPS"
      "HIST_IGNORE_ALL_DUPS"
      "HIST_SAVE_NO_DUPS"
      "HIST_FIND_NO_DUPS"
      "HIST_IGNORE_DUPS"
    ];

    autosuggestions.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
    };

    interactiveShellInit = ''

      bindkey -e
      bindkey '^H' backward-kill-word # Ctrl+Backspace (delete word backwards)
      bindkey '^[[3;5~' kill-word # Ctrl+Delete (delete word forwards)
      bindkey "^[[1;5C" forward-word # CTRL+ARROW_RIGHT
      bindkey "^[[1;5D" backward-word # CTRL+ARROW_LEFT
      bindkey "^Z" undo # CTRL+Z
      bindkey "^Y" redo # CTRL+Y
      bindkey "\e[5~" beginning-of-line # PgUp
      bindkey "\e[6~" end-of-line # PgDn

      eval "$(fzf --zsh)"
      eval "$(zoxide init --cmd cd zsh)"
      eval "$(oh-my-posh init zsh --config ~/.config/zsh/prompt.toml)"
    '';
  };
  hj.xdg.config.files."zsh/prompt.toml".text = dotfiles.ohmyposh "prompt.toml";
}
