{
  inputs = {
    unstable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    nixvim.url = "github:v0d1ch/nixvim";
    waybar.url = "github:Alexays/Waybar/master";
    herdr.url = "github:ogulcancelik/herdr/v0.8.0";

    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-openclaw.url = "github:openclaw/nix-openclaw";
  };
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} {
    systems = ["x86_64-linux"];
    # this gives us access to the flake-parts modules so we can import them
    imports = [
       inputs.flake-parts.flakeModules.modules
       ./modules/system-packages.nix
       ./modules/home.nix
    ];
    flake.nixosConfigurations = {
      nixos = inputs.unstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = 
            [
             ./nixos/configuration.nix 
             ./nixos/hardware-configuration.nix 
            ];
      };
      nixos-yoga = inputs.unstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [ 
                ./nixos-yoga/configuration.nix 
                ./nixos-yoga/hardware-configuration.nix 
                ];
      };
    };
  };
}
