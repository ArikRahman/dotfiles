# Dotfiles

My personal dotfiles configuration managed with [Nix](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager).

## Overview

This repository contains my declarative system configuration using Nix flakes. It focuses on creating a reproducible development environment with carefully selected tools and utilities.

## Features

### Shell & CLI Tools
- **Nushell** - Modern shell with intuitive syntax and powerful features
- **Starship** - Fast, customizable prompt
- **Atuin** - Shell history sync and search
- **Zoxide** - Smart directory jumping
- **Carapace** - Shell completion engine
- **Yazi** - Terminal file manager with preview
- **Lazygit** - Simple TUI for git commands

### Development Tools
- **Doom Emacs** - Customizable Emacs configuration
- **Helix** - Post-modern text editor (aliased to `vim`/`vi`)
- **Nix Language Server** (nixd, nil) - LSP support for Nix
- **Nixfmt** - Nix code formatter

### Utilities
- **Eza** - Modern replacement for `ls`
- **Fastfetch** - System information display
- **Discordo** - Discord TUI client
- **Cowsay** - ASCII art cow

## Structure

```
dotfiles/
├── flake.nix       # Flake configuration and inputs
├── home.nix        # Home Manager configuration
├── config.nu       # Nushell configuration (optional)
└── .doom.d/        # Doom Emacs configuration
```

## Setup

### Prerequisites
- [Nix](https://nixos.org/download.html) with flakes enabled
- [Home Manager](https://github.com/nix-community/home-manager)

### Installation

1. Clone this repository:
```bash
git clone <repo-url> ~/.config/dotfiles
cd ~/.config/dotfiles
```

2. Apply the configuration:
```bash
home-manager switch --flake .#arik
```

Or if you use `direnv`:
```bash
direnv allow
```

## Usage

### Shell Aliases
- `vi` / `vim` - Opens Helix editor
- `lz` - Opens Lazygit
- `y` - Opens Yazi file manager with directory jumping

### Development
```bash
nix develop          # Activate development shell
nix fmt             # Format all Nix files
```

## Customization

### Modifying Programs
Edit `home.nix` to enable/disable programs or adjust settings:
- Uncomment Nushell plugins as needed
- Adjust shell aliases
- Modify Starship prompt settings
- Configure Atuin sync

### Adding Packages
Add packages to the `home.packages` section in `home.nix`:
```nix
home.packages = with pkgs; [
  # existing packages
  new-package-here
];
```

### Doom Emacs
Edit configurations in `.doom.d/` directory to customize your Emacs setup.

## Platforms

This flake is configured to support multiple systems:
- `x86_64-linux` - 64-bit Intel/AMD Linux
- `aarch64-linux` - 64-bit ARM Linux
- `x86_64-darwin` - 64-bit Intel macOS
- `aarch64-darwin` - 64-bit ARM macOS

Currently configured for `aarch64-darwin` (Apple Silicon macOS).

## Notes

- Home Manager state version is pinned to `25.05`
- Nushell is the primary shell with customized completions and environment variables
- The configuration uses unfree packages (allowed via nixpkgs config)
- Some packages like neohtop don't work well as applications in this setup

## License

These are personal dotfiles. Feel free to use as inspiration for your own configuration!