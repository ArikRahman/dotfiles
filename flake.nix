{
  description = "Arik's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    zen-browser.url = "github:youwen5/zen-browser-flake";

    # Add musnix
    musnix.url = "github:musnix/musnix";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    doomemacs = {
      url = "github:doomemacs/doomemacs";
      flake = false;
    };

    nix-doom-emacs-unstraightened = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      # Common pattern used in examples: do not force-follow your nixpkgs
      inputs.nixpkgs.follows = "";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    {
      nixosConfigurations.arik = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };

        modules = [

          # Enable musnix module (you still need musnix.enable = true; in configuration.nix)
          inputs.musnix.nixosModules.musnix

          ./configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };

            # Import Doom’s HM module and your user HM config.
            home-manager.users.arik =
              { ... }:
              {
                imports = [
                  inputs.nix-doom-emacs-unstraightened.homeModule
                  ./home.nix
                ];
              };
          }
        ];
      };
    };
}
