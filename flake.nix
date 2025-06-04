{
  description = "NixOS configuration with Zed from unstable";

  inputs = {
    # NixOS official package source, using the nixos-25.05 branch here
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixvim.url = "github:nix-community/nixvim";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixvim, ... }@inputs: {
    # Please replace my-nixos with your hostname
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # Pass inputs to modules
      specialArgs = { inherit inputs; };

      modules = [
        ({ config, pkgs, ... }:
          let
            unstable = import nixpkgs-unstable {
              inherit (pkgs) system;
              config.allowUnfree = true;
            };
          in
          {
            nixpkgs.overlays = [
              (final: prev: {
                zed-editor = unstable.zed-editor;
              })
            ];
          }
       	)
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./configuration.nix
       	nixvim.nixosModules.nixvim
      ];
    };
  };
}
