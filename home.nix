{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  doomPrivateDir = ./.doom.d;
in
{
  ############################
  # Identity
  ############################
  home.username = "arik";
  home.homeDirectory = "/home/arik";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  ############################
  # XDG + Doom env vars
  ############################
  xdg.enable = true;

  home.sessionVariables = {
    EMACSDIR = "${config.xdg.configHome}/emacs";
    DOOMDIR = "${config.xdg.configHome}/doom";
    DOOMLOCALDIR = "${config.xdg.dataHome}/doom";
    DOOMPROFILELOADFILE = "${config.xdg.stateHome}/doom-profiles-load.el";
  };

  home.sessionPath = [
    "${config.xdg.configHome}/emacs/bin"
  ];

  ############################
  # Doom Emacs (module)
  ############################
  programs.doom-emacs = {
    enable = true;
    doomDir = doomPrivateDir;
  };

  ############################
  # Put Doom + config in XDG
  ############################
  xdg.configFile."emacs".source = inputs.doomemacs;
  xdg.configFile."doom".source = doomPrivateDir;

  ############################
  # Packages (single definition)
  ############################
  home.packages = with pkgs; [
    git
    fd
    (ripgrep.override { withPCRE2 = true; })

    gnumake
    cmake
    pkg-config

    emacs-all-the-icons-fonts
    fontconfig
    nerd-fonts.fira-code

    spacedrive
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

    nixfmt-rfc-style
    nil
    nixd
  ];

  fonts.fontconfig.enable = true;

  ############################
  # Shells / terminal
  ############################
  programs.fish.enable = true;

  programs.nushell = {
    enable = true;

    # Use config.nu from this same directory (next to home.nix)
    configFile.source = ./config.nu; # Home Manager supports configFile.source for Nushell. [web:1][web:17]
  };

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
    package = pkgs.ghostty;
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
}
