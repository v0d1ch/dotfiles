{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    nixvim.url = "./nixvim";
  };
  outputs = attrs@{ self, nixpkgs,  ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [./nixos/configuration.nix ];
    };
    nixosConfigurations.nixos-yoga = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [ ./nixos-yoga/configuration.nix ];
    };
  };
}
