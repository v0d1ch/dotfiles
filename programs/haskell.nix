{ pkgs, ... }:
{
  home.packages = with pkgs.haskellPackages; [
    hoogle
    hasktags
    stylish-haskell
    ghcid
    cabal2nix
    haskell-language-server
    dhall
    cabal-install
    xmobar
    xmonad
    yeganesh
    cachix
    styx
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
