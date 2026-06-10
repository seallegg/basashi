{ config, lib, pkgs, ... }: {
  options.basashi.terminal.agents.enable = lib.mkEnableOption "ai command line utilities";
  config = lib.mkIf config.basashi.terminal.agents.enable {
    hj.packages = with pkgs; [ claude-code gemini-cli ];
    environment.sessionVariables = {
      # god only knows why I can't use $XDG_CONFIG_HOME here
      # it exports as "/.config/claude", on root if I do
      CLAUDE_CONFIG_DIR = "$HOME/.config/claude";
      GEMINI_DIR = "$HOME/.config/gemini";
    };
  };
}
