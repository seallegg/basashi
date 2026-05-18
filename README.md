# basashi
_馬刺し - Thinly sliced, raw horse meat; horse sashimi._

My personal multi-host NixOS configuration. Accidentally organized according to a synaptic pattern through inheriting it from [fazzi's NixOhEss](https://gitlab.com/fazzi/nixohess).

Built by a very sloppy hobbyist, for personal use. Always a WIP. If you like it, cool. If you steal it, also cool.

### hosts
- **columbia**: gaming desktop (7800X3D + 4070 Super).
- **challenger**: university workhorse (Thinkpad L13 Gen 3 AMD).
- **discovery**: homelab, NAS and 3D printer controller (ender-6).

### structure
Might not make much sense, but doesn't make zero sense either.

- **`imports.nix`**: automates the recursive discovery of hosts, modules, and dotfiles.
- **`modules/`**: self-contained, mostly per-feature modules. Divided into `core`, `desktop`, `services`, and `terminal`. 
- **`dotfiles/`**: raw configuration files that are too big to go inline in modules comfortably.
- **`hosts/`**: one machine, one file. hostname is sourced from the filename. feature toggles live at the top, partitioning with disko at the bottom.
