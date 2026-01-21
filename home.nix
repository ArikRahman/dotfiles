{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:

let

  extension = shortId: guid: {
    name = guid;
    value = {
      install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
      installation_mode = "normal_installed";
    };
  };

  prefs = {
    "extensions.autoDisableScopes" = 0;
    "extensions.pocket.enabled" = false;
  };

  extensions = [
    (extension "ublock-origin" "uBlock0@raymondhill.net")
    (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
    (extension "darkreader" "addon@darkreader.org")
    (extension "private-grammar-checker-harper" "harper@writewithharper.com")
    (extension "youtube-recommended-videos" "myallychou@gmail.com")
  ];

  zenWrapped =
    pkgs.wrapFirefox
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped
      {
        extraPrefs = lib.concatLines (
          lib.mapAttrsToList (
            name: value: "lockPref(${lib.strings.toJSON name}, ${lib.strings.toJSON value});"
          ) prefs
        );

        extraPolicies = {
          DisableTelemetry = true;
          ExtensionSettings = builtins.listToAttrs extensions;

          # Custom search engines (Firefox/Zen enterprise policies).

          #

          # NOTE:

          # - This config is modeled after the reference `configuration.nix` you shared.

          # - These show up as selectable search engines; `Default` sets the default.

          # - Brave here refers to **Brave Search**, not the Brave browser.

          SearchEngines = {

            Default = "Brave Search";

            Add = [

              {

                Name = "Brave Search";

                URLTemplate = "https://search.brave.com/search?q={searchTerms}";

                IconURL = "https://search.brave.com/favicon.ico";

                Alias = "@bs";

              }

              {

                Name = "nixpkgs packages";

                URLTemplate = "https://search.nixos.org/packages?query={searchTerms}";

                IconURL = "https://wiki.nixos.org/favicon.ico";

                Alias = "@np";

              }

              {

                Name = "NixOS options";

                URLTemplate = "https://search.nixos.org/options?query={searchTerms}";

                IconURL = "https://wiki.nixos.org/favicon.ico";

                Alias = "@no";

              }

              {

                Name = "NixOS Wiki";

                URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";

                IconURL = "https://wiki.nixos.org/favicon.ico";

                Alias = "@nw";

              }

              {

                Name = "noogle";

                URLTemplate = "https://noogle.dev/q?term={searchTerms}";

                IconURL = "https://noogle.dev/favicon.ico";

                Alias = "@ng";

              }

              {

                Name = "GitHub";

                URLTemplate = "https://github.com/search?q={searchTerms}";

                IconURL = "https://github.com/favicon.ico";

                Alias = "@gh";

              }

            ];

          };
        };
      };

  # NOTE: Disabled per request to remove hyprsunset from this repo.
  #
  # hyprsunsetctl = pkgs.writeShellScriptBin "hyprsunsetctl" ''
  #   set -euo pipefail
  #
  #   uid="$(id -u)"
  #   base="''${XDG_RUNTIME_DIR:-/run/user/$uid}/hypr"
  #   hyprctl_bin="${pkgs.hyprland}/bin/hyprctl"
  #
  #   if [ ! -d "$base" ]; then
  #     echo "hyprsunsetctl: expected Hyprland runtime dir at: $base" >&2
  #     exit 1
  #   fi
  #
  #   # Prefer the current shell's instance if it exists.
  #   sig=""
  #   if [ -n "''${HYPRLAND_INSTANCE_SIGNATURE-}" ] && [ -S "$base/''${HYPRLAND_INSTANCE_SIGNATURE}/.socket.sock" ]; then
  #     sig="''${HYPRLAND_INSTANCE_SIGNATURE}"
  #   else
  #     # Otherwise, probe candidates (newest first) until one responds.
  #     while IFS= read -r d; do
  #       [ -n "$d" ] || continue
  #       csig="$(basename "$d")"
  #       if HYPRLAND_INSTANCE_SIGNATURE="$csig" "$hyprctl_bin" -j monitors >/dev/null 2>&1; then
  #         sig="$csig"
  #         break
  #       fi
  #     done < <(
  #       for d in "$base"/*; do
  #         [ -S "$d/.socket.sock" ] || continue
  #         echo "$(stat -c '%Y %n' "$d")"
  #       done | sort -nr | awk '{print $2}'
  #     )
  #   fi
  #
  #   if [ -z "${"sig:-"}" ]; then
  #     echo "hyprsunsetctl: couldn't find a Hyprland instance socket in: $base" >&2
  #     exit 1
  #   fi
  #
  #   export HYPRLAND_INSTANCE_SIGNATURE="$sig"
  #   exec "$hyprctl_bin" hyprsunset "$@"
  # '';

  # Hydenix theme selection
  #
  # IMPORTANT: `SUPER + SHIFT + T` changes the theme at runtime, but Hydenix will
  # revert to whatever is configured in Nix on the next rebuild/relog/reboot.
  # Set this to the exact theme name shown by the theme picker to make it
  # persist across `nixos-rebuild`.
  desiredTheme = "Catppuccin Mocha";
in
{
  imports = [
    # NOTE (2026-01-17):
    # This configuration previously imported an external Home Manager module here.
    # It has been removed per request. Keeping an empty imports list so Home Manager evaluation remains valid.
  ];

  # niri config ownership (full ownership: repo is the single source of truth)
  #
  # Why:
  # - Your running niri instance reads `~/.config/niri/config.kdl`.
  # - DMS appears to have written/overwritten that file (you have `~/.config/niri/config.kdl.dmsbackup...`).
  # - Editing `dotfiles/config.kdl` won't affect runtime unless Home Manager deploys it to `~/.config/niri/config.kdl`.
  #
  # What this does:
  # - Installs (symlinks) `dotfiles/config.kdl` as `~/.config/niri/config.kdl` declaratively.
  # - This makes settings like `focus-follows-mouse` and your binds (e.g. `Mod+D`) actually apply.
  #
  # What I got wrong earlier:
  # - I assumed `dotfiles/config.kdl` was already the live config. It isn't.
  #
  # How I corrected it:
  # - Home Manager now owns `~/.config/niri/config.kdl` so the repo config is the active runtime config.
  xdg.enable = true;
  xdg.configFile."niri/config.kdl".source = ./config.kdl;

  home.username = "arik";
  home.homeDirectory = "/home/arik";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # NOTE (2026-01-17):
  # A third-party `programs.*` block previously lived here and has been removed per request.
  programs.alacritty.enable = true;

  # Fuzzel theming
  #
  # Why:
  # - By default, fuzzel can look like a blinding white box depending on your theme / GTK defaults.
  # - This pins a dark, readable look directly in Home Manager so it’s consistent.
  #
  # What was wrong (symptom):
  # - fuzzel rejected keys like:
  #   - `[main].alpha`, `[main].theme`
  #   - `[main].background-color`, `[main].text-color`, etc.
  #
  # What I got wrong earlier:
  # - I assumed the CLI-flag-style names belonged under `[main]`.
  #
  # How I corrected it:
  # - Per `man fuzzel.ini` for fuzzel 1.13.1, colors live under `[colors]` with keys like:
  #   `background`, `text`, `match`, `selection`, `selection-text`, `selection-match`, `border`.
  # - Border geometry belongs under `[border]` (`width`, `radius`).
  #
  # NOTE:
  # - Fuzzel colors are RGBA (8-digit hex), no prefix (RRGGBBAA), e.g. `1d2021ff`.
  programs.fuzzel = {
    enable = true;

    settings = {
      colors = {
        # Dark, readable palette (roughly gruvbox-dark-ish)
        background = "1d2021ff";
        text = "ebdbb2ff";
        match = "b8bb26ff";
        selection = "3c3836ff";
        selection-text = "fbf1c7ff";
        selection-match = "b8bb26ff";
        border = "504945ff";
      };

      border = {
        width = 2;
        radius = 10;
      };
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      # Keep HM-managed settings here.

      # Allow machine-local, writable overrides:
      include.path = "~/.config/git/config.local";
    };
  };
  #programs.zoxide.enable = true;
  programs.zsh.enable = true;
  programs.zsh.dotDir = "${config.xdg.configHome}/zsh";
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;

    # Ghostty doesn't have a dedicated Home Manager option for Nushell
    # integration (unlike bash/fish/zsh), but you can still:
    # 1) make Ghostty *launch* Nushell by default via `command`
    # 2) optionally tell Ghostty what kind of prompt semantics to expect via `shell-integration`
    #
    # NOTE: `command` should point to the Nu binary in PATH. If Nu isn't
    # installed in Home Manager/system yet, you'll need to add `pkgs.nushell`.
    settings = {
      command = "nu";
      # shell-integration = "none";

      background-opacity = "0.7";
      theme = desiredTheme;
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;
  };

  programs.atuin = {
    enable = true;
    settings = {
      search_mode = "fuzzy";
    };
  };

  programs.nushell = {
    enable = true;

    # Use config.nu from this same directory (next to home.nix)
    configFile.source = ./config.nu; # Home Manager supports configFile.source for Nushell. [web:1][web:17]
  };

  programs.zed-editor = {
    enable = true;
    userSettings = {
      theme = desiredTheme; # must match an installed Zed theme name
      ui_font_size = 16;
      buffer_font_size = 14;
      terminal = {
        shell = {
          with_arguments = {
            program = "nu";
            args = [ "-i" ];
          };
        };
      };
      # Add Nix language support extension for syntax highlighting and features
      extensions = [ "zed-industries.extensions.nix" ];
    };
  };

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      # ble.sh / Bash integration
      #
      # What was wrong (symptom):
      # - `bash: fg: current: no such job`
      # - `[ble: exit 1]`
      #
      # What I got wrong earlier:
      # - I treated this like "bash is broken".
      # How I corrected it:
      # - `[ble: ...]` indicates ble.sh is active; the issue is the ble.sh init snippet / prompt hooks,
      #   not bash itself.
      #
      # Primary fix:
      # - Remove the literal `...` (invalid bash).
      # - Use a single, guarded attach strategy for interactive shells.

      # Previous (kept for history; DO NOT re-enable as-is):
      # [[ $- == *i* ]] && source -- "$(blesh-share)"/ble.sh --attach=none
      # ...
      # [[ ! ''${BLE_VERSION-} ]] || ble-attach

      # Only initialize ble.sh in interactive shells.
      case "$-" in
        *i*)
          # Single-attach initialization (more robust than split attach/attach=none).
          # If blesh isn't installed or blesh-share isn't available, do nothing.
          if command -v blesh-share >/dev/null 2>&1; then
            source -- "$(blesh-share)"/ble.sh
          fi
          ;;
      esac
    '';
  };

  home.packages = with pkgs; [
    #comment about what each package does, don't delete my comments next to each pkg
    zenWrapped

    # brave
    signal-desktop
    github-desktop
    # dorion
    syncthing
    cachix

    #inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    #Applications
    ayugram-desktop
    boxflat
    localsend # airdrop
    #swaybg
    spacedrive
    calibre # book manager
    neohtop # procmon
    nautilus
    obsidian
    qbittorrent
    legcord
    reaper
    logseq
    obs-studio
    webex
    vscodium-fhs # nix friendly codium

    seahorse

    #Terminal tools
    cava
    atool
    httpie
    discordo # terminal discord
    blesh # oh my bash
    fzf
    fastfetch
    eza # modern ls
    tokei # code counter
    dust # disk space checker like windirstat for windows
    sqlite
    yq # yaml processor and json as well
    lazygit
    ripgrep-all # rga, ripgrep with extra file format support
    gh
    just
    bottom # rust based top
    zenith # more traditional top based on rust
    nvd # useful for seeing difference in nix generations. syntax e.g.
    # ```nvd diff /nix/var/nix/profiles/system-31-link /nix/var/nix/profiles/system-30-link```
    gdb # for debugging
    yazi # file manager

    #LSP and language tooling
    #clojure-lsp
    nil
    nixd
    nix-ld
    package-version-server
    #Nix tooling ^
    marksman
    fswatch
    ruff # python lsp rust based
    zellij

    #Language
    babashka
    clojure
    clojure-lsp
    jdk25 # LTS until 2031
    python3
    # Rust toolchain (nixpkgs method; pinned by your flake input)
    #
    # Why:
    # - The NixOS Rust wiki recommends installing via nixpkgs for simplicity + determinism.
    # - This provides a stable toolchain suitable for most Rust development without rustup.
    #
    # Includes:
    # - `rustc` + `cargo` for compiling/building
    # - `rustfmt` + `clippy` for formatting/linting
    # - `rust-analyzer` for editor LSP
    #
    # NOTE:
    # - Some editor setups need rust source (`RUST_SRC_PATH`) to be set; handled via
    #   `home.sessionVariables.RUST_SRC_PATH` below.
    # rustc
    # cargo
    # rustfmt
    # clippy
    # rust-analyzer
    carapace

    # C/FFI helpers commonly needed by Rust crates (bindgen, openssl-sys, etc.)
    #
    # Why:
    # - The NixOS Rust wiki notes that crates using `bindgen` and crates that link against
    #   system libs often need:
    #   - `pkg-config` to locate libraries
    #   - a C compiler / libc headers (provided by `clang` in typical setups)
    #
    # NOTE:
    # - You may still need to add specific libs (e.g. `openssl`, `sqlite`) per-project.
    # - Keeping these here helps with the common “linking with cc failed” class of errors.
    # pkg-config
    clang

    uv
    # nim

    #jdk25 # jvm will outperform graalvm AOT with implementation of project leydus
    # graalvmPackages.graalvm-ce

    pandoc # haskell based document converter
    #protontricks

    #AC prereqs
    curl
    wget
    unzip
    pandoc # document converter

    protontricks

    # Preferred over screen shaders: hyprsunset uses Hyprland's CTM control,
    # so the filter won't show up in screenshots / recordings.
    #
    # NOTE: Disabled per request to remove hyprsunset from this repo.
    # hyprsunset
    # hyprsunsetctl
    # pkgs.vscode - hydenix's vscode version
    # pkgs.userPkgs.vscode - your personal nixpkgs version

    # Niri tooling
    alacritty
    dms-shell
    # NOTE (2026-01-17):
    # `quickshell` was previously included as part of a now-removed shell stack.
    # It has been commented out per request to remove that stack's traces.
    # If you still want Quickshell for other reasons, re-add it explicitly here.
    # quickshell
    # fuzzel
    # NOTE (2026-01-17):
    # A prior shell-related note was removed here per request; keeping the list tidy and neutral.
    #swaybg
  ];

}
