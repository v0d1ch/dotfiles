{ pkgs, ... }:
{
  home.packages = with pkgs.haskellPackages; [
    hoogle
    hasktags
    hlint
    stylish-haskell
    cabal2nix
    ghcid
    dhall
    cabal-install
    stack
    xmobar
    xmonad
    yeganesh
    cabal2nix
  ];

  home.file = {
    # ghci
    ".ghci".text = ''
      :set prompt "λ> "
    '';
  };
}
