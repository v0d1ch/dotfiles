{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };
  outputs = inputs@{ self, nixpkgs, unstable, ... }: {
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
