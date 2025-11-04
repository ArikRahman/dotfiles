{ pkgs, ... }:
{
  home.username = "arik";
  home.homeDirectory = "/Users/arik";
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  # Enable Nushell
  programs.nushell.enable = true;
  # programs.nushell.plugins = with pkgs.nushellPlugins; [
  #   nu-bookmarks
  #   nu-fetch
  #   nu-history
  #   nu-ls
  #   nu-nix
  #   nu-pkgs
  #   nu-web-get
  # ];

  # example packages
  home.packages = with pkgs; [
    nixfmt-rfc-style
    cowsay
    nil
    nixd
    lazygit
    neohtop
    fastfetch
  ];

}
