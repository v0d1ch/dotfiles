{ pkgs, ... }:
{
  home.packages = with pkgs.haskellPackages; [
    hoogle
    hasktags
    stylish-haskell
    ghcid
    cabal2nix
    dhall
    cabal-install
    xmobar
    xmonad
    yeganesh
    cachix
    styx
    z3
  ];

  home.file = {
    # ghci
    ".ghci".text = ''
      :set -fobject-code
      :set prompt      "λ> "
      :set prompt-cont "|> "
    '';
  };
}
