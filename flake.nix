{
  inputs = {
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    nixvim.url = "github:v0d1ch/nixvim";
  };
  outputs = inputs@{ self, unstable, ... }: {
    nixosConfigurations.nixos = unstable.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [./nixos/configuration.nix ];
    };
    nixosConfigurations.nixos-yoga = unstable.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [ ./nixos-yoga/configuration.nix ];
    };
  };
}
