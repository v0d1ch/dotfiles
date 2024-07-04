{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
  };
  outputs = inputs@{ self, nixpkgs,  ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [inputs.home-manager.nixosModules.default ./nixos/configuration.nix ];
    };
    nixosConfigurations.nixos-yoga = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ inputs.home-manager.nixosModules.default ./nixos-yoga/configuration.nix ];
    };
  };
}
