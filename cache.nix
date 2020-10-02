{ config, lib, pkgs, ... }:

{
  # NOTE: These caches are used on NixOS (nixos-rebuild) only, and not in
  # home-manager (which would only use the user's nix.conf).

  nix.binaryCaches = [
    "https://nixcache.reflex-frp.org"
    "https://hercules-ci.cachix.org/"
  ];
  nix.binaryCachePublicKeys = [
    "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI="
    "hercules-ci.cachix.org-1:ZZeDl9Va+xe9j+KqdzoBZMFJHVQ42Uu/c/1/KMC5Lw0="
  ];
}
