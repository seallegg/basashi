{ config, lib, pkgs, ... }:
let
  # create a shared "supervision" tab in kitty the user and an ai agent can both
  # watch driven over kitty's remote-control socket (see kitty.nix: listen_on).
  # this command is essentially reserved for use by AI
  ksup = pkgs.writeShellApplication {
    name = "ksup";
    runtimeInputs = [ pkgs.kitty pkgs.coreutils ];
    text = ''
      # kitty pid-suffixes its socket, so only the env var knows it
      if [ -z "''${KITTY_LISTEN_ON:-}" ]; then
        echo "ksup: KITTY_LISTEN_ON unset (not running inside kitty?)" >&2
        exit 1
      fi
      sock="$KITTY_LISTEN_ON"
      state="''${XDG_RUNTIME_DIR:-/tmp}/ksup.window"

      kc() { kitten @ --to "$sock" "$@"; }

      # print the id of a live supervision window, else return 1
      get_window() {
        local id
        [ -f "$state" ] || return 1
        id="$(cat "$state")"
        [ -n "$id" ] || return 1
        kc get-text --match "id:$id" --extent screen >/dev/null 2>&1 || return 1
        printf '%s' "$id"
      }

      # check id; create the tab if absent
      ensure_window() {
        local id
        if id="$(get_window)"; then
          printf '%s' "$id"
        else
          id="$(kc launch --type=tab --tab-title=claude-sup --cwd="$PWD")"
          printf '%s' "$id" >"$state"
          printf '%s' "$id"
        fi
      }

      require_window() {
        local id
        if id="$(get_window)"; then
          printf '%s' "$id"
        else
          echo "ksup: no supervision tab (run 'ksup run <cmd>' first)" >&2
          return 1
        fi
      }

      usage() {
        printf '%s\n' \
          "usage: ksup <command>" \
          "  run <cmd...>     open/reuse the supervision tab and run a command in it" \
          "  read [extent]    dump tab text (screen|last_cmd_output|all; default screen)" \
          "  key <keys...>    send key events (e.g. q, ctrl+c, enter)" \
          "  text <str...>    type literal text (no Enter)" \
          "  show             focus the supervision tab" \
          "  close            close the supervision tab" \
          "  status           report whether a supervision tab is alive" >&2
        exit 2
      }

      main() {
        local cmd id
        cmd="''${1:-}"
        shift || true
        case "$cmd" in
        run)
          [ "$#" -gt 0 ] || usage
          id="$(ensure_window)"
          kc send-text --match "id:$id" -- "$*"
          kc send-key --match "id:$id" enter
          ;;
        read)
          id="$(require_window)" || exit 1
          kc get-text --match "id:$id" --extent "''${1:-screen}"
          ;;
        key)
          [ "$#" -gt 0 ] || usage
          id="$(require_window)" || exit 1
          kc send-key --match "id:$id" "$@"
          ;;
        text)
          [ "$#" -gt 0 ] || usage
          id="$(require_window)" || exit 1
          kc send-text --match "id:$id" -- "$*"
          ;;
        show)
          id="$(require_window)" || exit 1
          kc focus-window --match "id:$id"
          ;;
        close)
          id="$(require_window)" || exit 1
          kc close-window --match "id:$id"
          rm -f "$state"
          ;;
        status)
          if id="$(get_window)"; then
            echo "ksup: supervision tab alive (window id $id)"
          else
            echo "ksup: no supervision tab"
          fi
          ;;
        *) usage ;;
        esac
      }

      main "$@"
    '';
  };
in { config = lib.mkIf config.basashi.terminal.agents.enable { hj.packages = [ ksup ]; }; }
