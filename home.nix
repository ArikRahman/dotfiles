{ pkgs, ... }:
{
  home.username = "arik";
  home.homeDirectory = "/Users/arik";
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  # Enable Nushell
  programs.nushell.enable = true;
  programs.nushell.config = ''
    alias lz = lazygit
  '';

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
