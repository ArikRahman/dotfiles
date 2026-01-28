# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  self,
  ...
}:

{
  # Track the exact flake revision that produced this system build.
  #
  # Why:
  # - This makes `nixos-version --configuration-revision` (and related tooling)
  #   report the git commit of your dotfiles flake when it was built from a commit.
  # - If the tree is dirty, Nix may expose `self.dirtyRev` instead.
  #
  # Notes:
  # - This reads revision metadata provided by the flake (`self.rev` / `self.dirtyRev`).
  # - It will be `null` if the flake source doesn’t have revision info available.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Niri X11 app support (Steam, etc.) via xwayland-satellite
  #
  # Why:
  # - niri (since 25.08) integrates with `xwayland-satellite` automatically.
  # - When available in `$PATH`, niri will:
  #   - create X11 sockets (e.g. `:0`)
  #   - export `$DISPLAY`
  #   - spawn xwayland-satellite on-demand when an X11 client (like Steam) connects
  # - Without this, X11 apps can fail with errors like:
  #   “Unable to open a connection to X” / “Check your DISPLAY environment variable…”
  #
  # Source: https://yalter.github.io/niri/Xwayland.html
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Steam baseline (system-level)
  #
  # Why:
  # - The NixOS Steam module is the most reliable way to run Steam on NixOS.
  # - Most Steam/Proton issues on NixOS are missing 32-bit graphics/Vulkan support.
  #
  # What this enables:
  # - Steam client (with runtime) via `programs.steam.enable`
  # - 32-bit graphics userspace support (required for many games/Proton)
  programs.steam.enable = true;
  programs.nix-ld.enable = true;
  # Optional, but recommended: add common libs for unpackaged binaries.
  # programs.nix-ld.libraries = with pkgs; [
  #   stdenv.cc.cc
  #   zlib
  #   zstd
  # ];
  # Enable OpenGL/Vulkan plumbing; many games (and Steam itself) still need 32-bit.
  #
  # NOTE:
  # - On modern NixOS, these are the `hardware.graphics.*` options.
  # - If you later hit evaluation errors due to option name changes, we can adapt,
  #   but this is the correct direction on unstable for most setups.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Optional ports:
  # If you use any of these Steam features, uncomment the relevant line(s).
  #
  # Being conservative here (keep firewall changes minimal).
  # programs.steam.remotePlay.openFirewall = true;
  # programs.steam.dedicatedServer.openFirewall = true;
  # programs.steam.localNetworkGameTransfers.openFirewall = true;

  # Helpful utilities for Proton troubleshooting (system-wide).
  #
  # NOTE:
  # - You already have `protontricks` in Home Manager packages; leaving it there is fine.
  # - Duplicating packages across system + HM isn't harmful, but it's redundant.
  programs.gamemode.enable = true;

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
    # Pass flake inputs into home.nix so Home Manager modules can access `inputs.*` if needed. [web:24]
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

  # In your NixOS configuration (flake-based)
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # Critical for Wayland/Niri input emulation
    openFirewall = true; # Opens TCP 47984, 47989, 48010 & UDP 47998-48010
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true; # [web:201]

  services.desktopManager.gnome.enable = true;
  # Install niri system-wide (so niri + niri-session exist in /run/current-system/sw/bin)

  # Dank Material Shell (DMS) — Option 1 integration (keep GDM, run DMS in the user session)
  #
  # Why:
  # - You chose "1": keep the existing display manager (GDM) and run DMS as a user-session shell/service.
  # - This avoids replacing your login stack and is reversible by flipping these booleans back to false.
  #
  # Notes / assumptions:
  # - `dms-shell` is already present in your HM `home.packages` (see `home.nix`), so you may already
  #   have the binary. Enabling this NixOS module wires up the intended session/service integration.
  #
  # What I could have gotten wrong (to adjust after your first rebuild if needed):
  # - The best systemd user target for your setup. `graphical-session.target` is a common default so
  #   it starts when the graphical session is considered "up", but depending on how your niri session
  #   is launched from GDM you may prefer a different target exposed by your session environment.
  programs.dms-shell = {
    enable = true;

    # Run DMS via a systemd *user* service so it follows your login session lifecycle.
    systemd.enable = true;

    # Makes changes take effect cleanly on rebuild by restarting the user service when its unit changes.
    systemd.restartIfChanged = true;

    # Start DMS as part of the graphical user session.
    systemd.target = "graphical-session.target";
  };

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

    # Required for niri’s automatic X11 integration (xwayland-satellite >= 0.7).
    # It must be available in `$PATH` so niri can spawn it on-demand and export `$DISPLAY`.
    xwayland-satellite
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
  #
  # LocalSend (phone → PC receive)
  # Why:
  # - PC → phone works via outbound connections.
  # - phone → PC requires inbound access to the LocalSend listening port.
  #
  # Port:
  # - TCP 53317 (from your LocalSend settings)
  networking.firewall.allowedTCPPorts = [
    53317
  ];

  # If discovery still fails (device not found), LocalSend may also require UDP
  # for discovery/broadcast on your LAN. I’m leaving UDP closed for now to keep
  # the firewall change minimal; we can open the exact UDP port once confirmed.
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
