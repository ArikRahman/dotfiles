{
  description = "NixOS + niri (nixpkgs)";

  inputs = {

    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-doom-emacs-unstraightened.url = "github:marienz/nix-doom-emacs-unstraightened";
    nix-doom-emacs-unstraightened.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.arik = nixpkgs.lib.nixosSystem {
        inherit system;

        # Expose the flake itself to NixOS modules so they can read revision metadata
        # like `self.rev` / `self.dirtyRev` (used for `system.configurationRevision`,
        # `nixos-version`, etc.).
        specialArgs = { inherit inputs self; };

        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
        ];
      };
    };
}
