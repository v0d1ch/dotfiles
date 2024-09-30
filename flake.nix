{
  inputs = {
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    nixvim.url = "github:v0d1ch/nixvim";
  };
  outputs = attrs@{ self, unstable,  ... }: {
    nixosConfigurations.nixos = unstable.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [./nixos/configuration.nix ];
    };
    nixosConfigurations.nixos-yoga = unstable.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [ ./nixos-yoga/configuration.nix ];
    };
  };
}
