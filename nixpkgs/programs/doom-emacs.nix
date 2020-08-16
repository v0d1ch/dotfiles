{ pkgs, ... }:
let
  doom-emacs = pkgs.callPackage (builtins.fetchGit {
    url = "https://github.com/vlaci/nix-doom-emacs";
    rev = "c440f4afe4ff2d38d2beb40d7e4bcfa2496f60c2";
  }) {
    doomPrivateDir = "~./doom.d";  # Directory containing your config.el init.el and packages.el files
  };
in {
 home.packages = [ doom-emacs ];
 home.file.".emacs.d/init.el".text = ''
     (load "default.el")
 '';
}
