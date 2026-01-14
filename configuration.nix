# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Enable the modern Nix CLI and Flakes (system-wide).
  #
  # Why:
  # - `nix flake ...` requires both `nix-command` and `flakes`.
  # - Putting this in NixOS config (instead of per-user nix.conf) keeps it reproducible and
  #   ensures the daemon/CLI behave consistently across users.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup-2026_01_13-19_33_59";
    # Pass flake inputs into home.nix so `inputs.dms...` works. [web:24]
    extraSpecialArgs = { inherit inputs; };

    users.arik = import ./home.nix;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
  # Fix audio buzzing on idle by disabling power saving on the Intel HDA driver

  boot.extraModprobeConfig = ''


    options snd_hda_intel power_save=0 power_save_controller=N


  '';

  # Syncthing (daemon)
  #
  # Why:
  # - Installing `syncthing` in `home.packages` only provides the CLI/binary; it does NOT keep it running.
  # - Enabling the NixOS module creates a proper systemd unit (`syncthing@arik.service`) that runs at boot.
  #
  # Safe defaults:
  # - GUI is left at Syncthing defaults (normally localhost:8384). We do NOT expose it to LAN here.
  # - We do NOT open firewall ports by default. If you want LAN syncing/discovery, toggle
  #   `openDefaultPorts = true;` below (or add explicit firewall rules).
  #
  # What I could have gotten wrong:
  # - Your desired sync root may not be `/home/arik`. If you prefer a dedicated folder like `/home/arik/Sync`,
  #   change `dataDir` accordingly.
  services.syncthing = {
    enable = true;

    # Run as your normal user (not root).
    user = "arik";
    group = "users";

    # Keep state in your home so it's easy to back up/migrate.
    #
    # NOTE:
    # - `configDir` contains device identity/certs and folder config (stateful).
    # - `dataDir` is where Syncthing stores its index database (not your synced folders by itself).
    configDir = "/home/arik/.config/syncthing";
    dataDir = "/home/arik/.local/state/syncthing";

    # LAN sync/discovery ports (TCP/UDP 22000 + UDP 21027).
    # Default is false here for security; enable if you want other devices on your LAN to connect directly.
    openDefaultPorts = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true; # [web:201]

  services.desktopManager.gnome.enable = true;
  # Install niri system-wide (so niri + niri-session exist in /run/current-system/sw/bin)

  # Make GDM show additional sessions (Wayland/X11) from these packages. [web:114]
  services.displayManager.sessionPackages = with pkgs; [
    niri
  ];

  environment.variables."NIXOS_OZONE_WL" = "1";
  environment.variables."ELECTRON_OZONE_PLATFORM_HINT" = "auto"; # to make github desktop work in niri
  #needs ELECTRON_OZONE_PLATFORM_HINT=auto github-desktop
  # services.greetd = {
  # enable = true;
  # settings.default_session = {
  # tuigreet can list Wayland/X11 sessions from these directories. [web:30][web:121]
  #  command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --sessions /run/current-system/sw/share/wayland-sessions --xsessions /run/current-system/sw/share/xsessions";
  # user = "greeter";
  #    };
  # };

  # Make GDM show additional sessions (Wayland/X11) from these packages. [web:114]
  #  services.displayManager.sessionPackages = with pkgs; [
  #   niri
  #];

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
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      #  thunderbird
      # git
      # ripgrep-all
    ];
  };

  # Install firefox.
  #  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    niri
  ];

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
  # on your system were taken. It’s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
