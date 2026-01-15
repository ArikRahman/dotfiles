## This is where commands are saved for future reference
do  ```git config --local credential.helper '!gh auth git-credential'``` to enable github cli authentication for git
do  ```sudo nixos-rebuild switch --flake .#hydenix ``` to update nixos

## Steam (notes + reproducible checks and commands)
### Reproducible checks (preferred)
- after any Nix config change related to Steam/graphics:
  - ```nix flake check```

- launch Steam from a terminal to capture stdout/stderr (useful when it doesn't open or games instantly quit):
  - ```steam```

### External drive Steam library (common breakage)
Ownership (Proton prefixes must be writable):
do  ```sudo chown -R arik:users '/mnt/arik_s disk/'``` to fix steam proton prefix ownership issues

Mount flags (Proton/games often fail if the library drive is mounted with `noexec`):
- sometimes have to run ```sudo mount -o remount,exec /mnt/arik_s_disk``` to make games work again because drive mounts with noexec

Note:
- The long-term reproducible fix is to ensure the filesystem mount is declared with correct options in NixOS so you don't need manual `chown`/`remount` steps each time.

do  ```nix flake update``` to update flake inputs
do  ```gh auth login``` to login to github cli
do  ```gh repo clone ArikRahman/hydenix``` to clone hydenix repo
do Optional: run ```nix flake update nixpkgs``` which will make Unstraightened reuse more dependencies already on your system.

## Syncthing daemon (reproducible verification)
After you enable Syncthing via NixOS (systemd unit `syncthing@arik.service`), use these commands to verify it is running and reachable:

- check service status:
  - ```sudo systemctl status syncthing@arik.service```

- follow logs:
  - ```sudo journalctl -u syncthing@arik.service -f```

- confirm GUI is listening locally (default is usually 127.0.0.1:8384):
  - ```ss -tulpn | grep 8384```

- confirm sync port is listening (default TCP/UDP 22000; discovery is typically UDP 21027):
  - ```ss -tulpn | grep 22000```
  - ```ss -u -lpn | grep 21027```

- open GUI (local):
  - ```xdg-open http://127.0.0.1:8384```

## Nix flakes enablement + validation (reproducible)
- Flakes + modern CLI are enabled declaratively in `configuration.nix` via:
  - `nix.settings.experimental-features = [ "nix-command" "flakes" ];`
- Validation (reproducible check after config changes): run ```nix flake check``` from the repo root

## Fuzzel config debugging (reproducible)
When fuzzel errors with `not a valid option`, the `fuzzel.ini` schema (sections/keys) doesn't match your installed fuzzel build. Use these commands to collect ground truth:

- check version:
  - ```fuzzel --version```

- check which config is being read and whether it parses:
  - ```fuzzel --check-config```
  - ```fuzzel --check-config --config ~/.config/fuzzel/fuzzel.ini```

- inspect the generated config:
  - ```sed -n '1,120p' ~/.config/fuzzel/fuzzel.ini```

- see available styling knobs (CLI flags + expected color format):
  - ```fuzzel --help | sed -n '1,220p'```

- check documentation for the INI schema (if present):
  - ```man fuzzel | sed -n '1,240p'```

Minimal schema probes (use temp config files so you can bisect which section/key names are accepted):
- create a minimal config file:
  - ```mkdir -p ~/tmp```
  - ```printf '%s\n' '[colors]' 'background=1d2021ff' > ~/tmp/fuzzel-min.ini```
  - ```fuzzel --check-config --config ~/tmp/fuzzel-min.ini```

If `[colors]` is rejected, try the same key under `[main]`, and then try underscore variants:
- ```printf '%s\n' '[main]' 'background_color=1d2021ff' > ~/tmp/fuzzel-min.ini```
- ```fuzzel --check-config --config ~/tmp/fuzzel-min.ini```

Note:
- `fuzzel --help` says colors are RGBA (8-digit hex), no prefix, e.g. `1d2021ff` (RRGGBBAA).

- dota 2 audio cuts out whenf inding match, fix with launch option ```-sdlaudiodriver pulse```
- had to use vscodium and delete existing .config git config file to override and git auth login would apply allowing cli git push to remote
- ```sudo chown -R arik:users "/run/media/arik/arik_s disk"``` to make external ssd work
- ```steam -console``` to log steam
