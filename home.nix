{ pkgs, ... }:
{
  home.username = "arik";
  home.homeDirectory = "/Users/arik";
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
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
