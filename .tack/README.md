quick refresher of some tack info that I will most certainly forget at some point

- After editing pins.toml, `tack update [names...]`
- `.tack/` must stay git-tracked
- you can dry run with `tack look`

- extra fields need an inline table like `name = { url = "...", dir = "subdir", exclude_follow = ["nixpkgs"] }`
- fields: `url`, `type`, `follows`, `exclude_follow`, `dir` (where flake is), `submodules`, `unpack`
  - `?dir=` in a github url is ignored, just use the `dir` field

- on types, besides flake acting like what you'd expect:
  - `fetch` pulls source without needing a flake, good for [themes and such](https://en.wikipedia.org/wiki/Chainsaw_Man#Themes)
  - `fixed` is hash-locked so `tack update` needs `--accept` to change it

- in `[all_follow]`, it's `alias = "target"` unless you're using a list, in which case it's `target = ["alias1", "alias2", "alias3"]`
