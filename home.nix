#home.nix
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
  xdg.configFile."niri/config.kdl".source = ./config.kdl;
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

    reaper
    yt-dlp
    yabridge
    yabridgectl

    git
    fd
    (ripgrep.override { withPCRE2 = true; })

    gnumake
    cmake
    pkg-config
    libdrm
    wget
    unzip

    protontricks
    emacs-all-the-icons-fonts
    fontconfig
    nerd-fonts.fira-code

    ayugram-desktop
    boxflat
    swaybg
    spacedrive
    neohtop
    gh
    atool
    httpie
    discordo
    #dorion
    # #^ not working rn try again later keep for reference
    legcord
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
    fuzzel
    nixfmt-rfc-style
    nil
    syncthing
    nixd
    ollama

    qbittorrent
    signal-desktop
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
      background-opacity = "0.9";
      theme = "Catppuccin Mocha";
    };
  };
  ##for niri
  programs.alacritty.enable = true; # Super+T in the default setting (terminal)
  programs.fuzzel.enable = true; # Super+D in the default setting (app launcher)
  programs.swaylock.enable = true; # Super+Alt+L in the default setting (screen locker)
  programs.waybar.enable = true; # launch on startup in the default setting (bar)
  services.mako.enable = true; # notification daemon
  services.swayidle.enable = true; # idle management daemon
  services.polkit-gnome.enable = true; # polkit

  services.emacs = {
    enable = true;

    # Helps avoid “daemon started too early” issues for GUI frames.
    startWithUserSession = "graphical";

    # Optional: makes $EDITOR use emacsclient
    defaultEditor = true;

    # IMPORTANT: use the Emacs package produced by the Doom module
    #package = config.programs.doom-emacs.package;
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium; # Use VSCodium as the VS Code build. [web:26]

    extensions = with pkgs.vscode-extensions; [
      catppuccin.catppuccin-vsc # Soothing pastel theme for VSCode. [page:4]
      # catppuccin.catppuccin-vsc-icons # Optional icon theme. [web:28]
    ];

    userSettings = {
      # Theme selection example from Catppuccin’s docs. [page:3]
      "workbench.colorTheme" = "Catppuccin Mocha";

      # Recommended settings from Catppuccin’s docs. [page:3]
      "editor.semanticHighlighting.enabled" = true;
      "terminal.integrated.minimumContrastRatio" = 1;
      "window.titleBarStyle" = "custom";
      "git.autofetch" = true;

    };
  };

  programs.zed-editor = {
    enable = true;
    userSettings = {
      theme = "Catppuccin Mocha"; # or Latte/Frappe/Macchiato depending on what the extension provides      ui_font_size = 16;
      buffer_font_size = 14;
      terminal = {
        program = "nu";
        with_arguments = [ "-i" ];
      };
    };
  };
}
