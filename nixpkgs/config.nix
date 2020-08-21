{ pkgs, ... }:
{
    allowUnfree = true;
    allowBroken = true;
    virtualisation.virtualbox.host.enable = true;
    virtualisation.virtualbox.host.enableExtensionPack = true;

    environment.pathsToLink = [ "/share" ];

}
