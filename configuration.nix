# dit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, lib, ... }:
let
#  home-manager = builtins.fetchTarball {
#  url = "https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz";

#};

  # Extension function for Firefox
  extension = shortId: guid: {
    name = guid;
    value = {
      install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
      installation_mode = "normal_installed";
    };
  };

  prefs = {
    # Check these out at about:config
    "extensions.autoDisableScopes" = 0;
    "extensions.pocket.enabled" = false;
    # Add more Firefox preferences if needed
  };

  extensions = [
    # Example extension, you can add more by following the same format
    (extension "ublock-origin" "uBlock0@raymondhill.net")
    (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
    (extension "darkreader" "addon@darkreader.org")
  ];

in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
#              (import "${home-manager}/nixos")
inputs.home-manager.nixosModules.home-manager

    ];
home-manager.backupFileExtension = "backup";
programs.steam = {
  enable = true;
  remotePlay.openFirewall = true;          # Optional: Remote Play
  dedicatedServer.openFirewall = true;     # Optional: Source DS
  localNetworkGameTransfers.openFirewall = true; # Optional: LAN transfers
};
      #users.users.arik.isNormalUser = true;
  home-manager.users.arik = { pkgs, ... }: {
    home.packages = with pkgs; [
    gh
   	atool          # Archive extraction tools for many formats
   	httpie         # Human-friendly command-line HTTP client
   	discordo       # Terminal Discord client
   	fd             # Simple, fast alternative to find
   	dust           # Disk usage with nicer interface
   	delta          # Enhanced git diff viewer
   	tokei          # Code statistics (language line counts)
   	hyperfine      # Command-line benchmarking tool
   	lsof           # List open files and sockets
   	bandwhich      # Network bandwidth utilization tool
   	jq             # JSON processor
   	radio-active   # Terminal internet radio player
   	fswatch        # File change monitor
   	ripgrep-all    # Ripgrep including many file types
   	eza            # Modern replacement for ls
   	bun            # Fast JavaScript runtime and tool
   	blesh          # ble.sh bash line-editing enhancement
   	fastfetch      # Fast system information fetcher
   	satty          # Wayland screenshot annotation tool
   	flameshot      # Screenshot capture and annotation tool
   	lazygit        # Simple terminal UI for git
   	just           # Command runner like Make
   	git            # Version control system
   	fzf            # Command-line fuzzy finder
 ];
 programs.ghostty = {
   enable = true;

   # Only needed for macOS; safe to keep cross-platform.
   package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;

   enableBashIntegration = true;
   enableFishIntegration = true;
   enableZshIntegration = true;

   settings = {
     # theme = "catppuccin-mocha";
     background-opacity = "0.95";
   };
 };





   programs.zed-editor = {
      enable = true;
      # extensions = [ "nix" "toml" "rust" "nu" ]; # Optional: add extensions
      userSettings = {
        theme = "One Dark"; # Or your preferred theme
        ui_font_size = 16;
        buffer_font_size = 14;
        # Use your system shells
        terminal = {
          program = "nu";            # the program binary to use
          with_arguments = ["-i"];   # optional args as a list
        };
      };
    };
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };
    programs.fish.enable = true;
    programs.nushell.enable = true;
#    programs.zed-editor.enable = true;
	programs.bash = {
    enable = true;
    bashrcExtra = ''
      [[ $- == *i* ]] && source -- "$(blesh-share)"/ble.sh --attach=none
      ...
      [[ ! ''${BLE_VERSION-} ]] || ble-attach
    '';
  };

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "25.11";

#     home.file.".local/share/applications/satty.desktop".text = ''
# [Desktop Entry]
# Name=Satty
# Comment=Take and annotate screenshots (Wayland)
# Exec=satty
# Icon=satty
# Type=Application
# Categories=Graphics;
# '';

#     # Attempt to set a GNOME custom keybinding (Print) to run Satty.
#     # This runs during `home-manager switch` if `gsettings` is available.
#     home.activation.satty-keybinding = {
#       text = ''
#         if command -v gsettings >/dev/null 2>&1; then
#           path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-satty/"
#           current=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings 2>/dev/null || echo "[]")
#           if echo "$current" | grep -q "$path"; then
#             new="$current"
#           elif [ "$current" = "[]" ]; then
#             new="['$path']"
#           else
#             new=$(python3 - "$current" "$path" <<'PY'
# import sys,ast
# s=sys.argv[1]
# p=sys.argv[2]
# try:
#     lst=ast.literal_eval(s)
# except Exception:
#     lst=[]
# if p not in lst:
#     lst.append(p)
# print(repr(lst))
# PY
# )
#           fi
#           gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$new" || true
#           gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path name 'Satty' || true
#           gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path command 'satty' || true
#           gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path binding 'Print' || true
#         else
#           echo "gsettings not found; please set a custom keybinding to run 'satty'."
#         fi
#       '';
#     };

  };

    nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-c8353ab7-a5b2-409d-bbfb-54baff97aca2".device = "/dev/disk/by-uuid/c8353ab7-a5b2-409d-bbfb-54baff97aca2";
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  # Enable the COSMIC login manager
  services.displayManager.cosmic-greeter.enable = true;

  # Enable the COSMIC desktop environment
  services.desktopManager.cosmic.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.arik = {
    isNormalUser = true;
    description = "arik";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Install Zen Browser
  environment.systemPackages = with pkgs; [
    (pkgs.wrapFirefox
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped
      {
        extraPrefs = lib.concatLines (
          lib.mapAttrsToList (
            name: value: ''lockPref(${lib.strings.toJSON name}, ${lib.strings.toJSON value});''
          ) prefs
        );

        extraPolicies = {
          DisableTelemetry = true;
          ExtensionSettings = builtins.listToAttrs extensions;

          SearchEngines = {
            Default = "ddg";
            Add = [
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
            ];
          };
        };
      }
    )
  ];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  #environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  #];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
