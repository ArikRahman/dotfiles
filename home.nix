{ config, pkgs, lib, inputs, ... }:

let
  # Keep your Doom private config in-repo at ./doom.d (recommended).
  doomDir = ./doom.d;

  # Convenience
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  ############################################################
  # Required Home Manager identity
  ############################################################
  home.username = "arik";
  home.homeDirectory = if isDarwin then "/Users/arik" else "/home/arik";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  ############################################################
  # XDG + Doom environment (important)
  ############################################################
  # This mirrors the working approach described in doomemacs-nix-example:
  # EMACSDIR in ~/.config/emacs, DOOMDIR in ~/.config/doom, mutable state in XDG data/state. [page:4]
  xdg.enable = true;

  home.sessionVariables = {
    # Where Doom's git checkout lives (read-only symlink is fine)
    EMACSDIR = "${config.xdg.configHome}/emacs";

    # Your private Doom config (packages.el, init.el, config.el)
    DOOMDIR = "${config.xdg.configHome}/doom";

    # Writable locations for Doom's package builds/cache/state
    DOOMLOCALDIR = "${config.xdg.dataHome}/doom";
    DOOMPROFILELOADFILE = "${config.xdg.stateHome}/doom-profiles-load.el";
  };

  # Ensure the `doom` script is on PATH as `doom` (it lives in $EMACSDIR/bin). [page:4]
  home.sessionPath = [
    "${config.xdg.configHome}/emacs/bin"
  ];

  ############################################################
  # Doom Emacs itself (via nix-doom-emacs-unstraightened HM module)
  ############################################################
  programs.doom-emacs = {
    enable = true;

    # This should point at a directory in your repo that contains Doom private config files.
    # Rename your old ./.doom.d -> ./doom.d (recommended) to avoid hidden-dir weirdness.
    doomDir = doomDir;
  };

  ############################################################
  # Put Doom’s code and your Doom config into XDG locations
  ############################################################

  # 1) Install Doom Emacs source into ~/.config/emacs.
  # The example repo fetches Doom via Nix into XDG config. [page:4]
  #
  # Option A (recommended): pin Doom as a flake input instead of fetchGit.
  # If you do that, replace this with: xdg.configFile."emacs".source = inputs.doomemacs;
  #
  # Option B: fetch Doom directly.
  xdg.configFile."emacs".source = builtins.fetchGit {
    url = "https://github.com/doomemacs/doomemacs";
    # Tip: pin this to a rev after first success for reproducibility.
    # rev = "....";
  };

  # 2) Symlink your private Doom config to ~/.config/doom. [page:4]
  xdg.configFile."doom".source = doomDir;

  ############################################################
  # Packages (include common Doom dependencies)
  ############################################################
  home.packages = with pkgs; [
    # General tooling Doom modules often assume
    git
    gnumake
    cmake
    pkg-config

    # Search/index dependencies commonly used by Doom
    fd
    (ripgrep.override { withPCRE2 = true; })

    # Optional but common quality-of-life
    unzip
    zip
    gnused
    gawk

    # Nix tooling
    nixfmt-rfc-style
    nil
    nixd

    # Your CLI picks (from your current config)
    neohtop
    gh
    atool
    httpie
    discordo
    dust
    delta
    tokei
    hyperfine
    lsof
    bandwhich
    jq
    radio-active
    fswatch
    ripgrep-all
    eza
    bun
    blesh
    fastfetch
    satty
    flameshot
    lazygit
    just
    fzf
  ];

  ############################################################
  # Terminal / shell setup (kept close to what you already had)
  ############################################################
  programs.nushell = {
    enable = true;
    extraConfig = ''
      # yazi 'y' alias
      def --env y [...args] {
        let tmp = (mktemp -t "yazi-cwd.XXXXXX")
        yazi ...$args --cwd-file $tmp
        let cwd = (open $tmp)
        if $cwd != "" and $cwd != $env.PWD { cd $cwd }
        rm -fp $tmp
      }

      let carapace_completer = {|spans|
        carapace $spans.0 nushell ...$spans | from json
      }

      $env.config = {
        show_banner: false,
        completions: {
          case_sensitive: false
          quick: true
          partial: true
          algorithm: "fuzzy"
          external: {
            enable: true
            max_results: 100
            completer: $carapace_completer
          }
        }
      }
    '';
  };

  programs.fish.enable = true;

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      [[ $- == *i* ]] && source -- "$(blesh-share)"/ble.sh --attach=none
      [[ ! ''${BLE_VERSION-} ]] || ble-attach
    '';
  };

  programs.carapace.enable = true;
  programs.carapace.enableNushellIntegration = true;

  programs.yazi.enable = true;

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

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  programs.ghostty = {
    enable = true;
    package = if isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    settings = {
      background-opacity = "0.95";
    };
  };

  programs.zed-editor = {
    enable = true;
    userSettings = {
      theme = "One Dark";
      ui_font_size = 16;
      buffer_font_size = 14;
      terminal = {
        program = "nu";
        with_arguments = [ "-i" ];
      };
    };
  };

  ############################################################
  # Fonts (optional, but helps Doom icon/fonts setups)
  ############################################################
  fonts.fontconfig.enable = true;

  home.packages = (home.packages or []) ++ (with pkgs; [
    fontconfig
    emacs-all-the-icons-fonts
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ]);
}
