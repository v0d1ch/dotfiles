{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, offline ? false
, OS ? "linux" }:
with lib;

let
    # builtins.fetchurl doesn'support 'sha1' hash. Which is strange, because it should
    # I've tried to overcome this with:
    # # fetchurlPath = builtins.toPath pkgs.nix + "/share/nix/corepkgs/fetchurl.nix";
    # # builtins_fetchurl = import fetchurlPath;
    # but looks like builtins.fetchurl wants some other kind of hash. So we stick with pkgs.fetchurl
    builtins_fetchurl = pkgs.fetchurl;

    buildMc = versionInfo: assetsIndex:
        let
            client = builtins_fetchurl {
                inherit (versionInfo.downloads.client)
                    url sha1
                ;
            };
            isAllowed = artifact:
                let
                    lemma1 = acc: rule:
                        if rule.action == "allow"
                            then if rule ? os then rule.os.name == OS else true
                            else if rule ? os then rule.os.name != OS else false
                        ;
                in if artifact ? rules
                    then foldl' lemma1 false artifact.rules
                    else true;
            artifacts = lib.filter isAllowed versionInfo.libraries;

            libPath = lib.makeLibraryPath [
                pkgs.libpulseaudio
                pkgs.xorg.libXcursor
                pkgs.xorg.libXrandr
                pkgs.xorg.libXxf86vm # Needed only for versions <1.13
                pkgs.libGL
            ];

        in pkgs.runCommand "minecraft-client-${versionInfo.id}" {
            version = versionInfo.id;
            buildInputs = [
                pkgs.unzip
                pkgs.makeWrapper
            ];
        } ''
            mkdir -p $out/bin $out/assets/indexes $out/libraries $out/natives
            ln -s ${client} $out/libraries/client.jar

            # Java libraries
            ${concatMapStringsSep "\n" (artif:
                let library = builtins_fetchurl {
                        inherit (artif.downloads.artifact)
                            url sha1
                        ;
                    };
            in ''
                mkdir -p $out/libraries/${builtins.dirOf artif.downloads.artifact.path}
                ln -s ${library} $out/libraries/${artif.downloads.artifact.path}
            '') (filter (x: !(x.downloads ? "classifiers")) artifacts)}

            # Native libraries
            ${concatMapStringsSep "\n" (artif:
                let library = builtins_fetchurl {
                        inherit (artif.downloads.classifiers.${artif.natives.${OS}})
                            url sha1
                        ;
                    };
            in ''
                unzip ${library} -d $out/natives && rm -rf $out/natives/META-INF
            '') (filter (x: (x.downloads ? "classifiers")) artifacts)}

            # Assets
            ${concatStringsSep "\n" (builtins.attrValues (flip mapAttrs assetsIndex.objects (name: a:
                let asset = builtins_fetchurl {
                        sha1 = a.hash;
                        url = "http://resources.download.minecraft.net/" + hashTwo;
                    };
                    hashTwo = builtins.substring 0 2 a.hash + "/" + a.hash;
            in ''
                mkdir -p $out/assets/objects/${builtins.substring 0 2 a.hash}
                ln -sf ${asset} $out/assets/objects/${hashTwo}
            '')))}
            ln -s ${builtins.toFile "assets.json" (builtins.toJSON assetsIndex)} \
                $out/assets/indexes/${versionInfo.assets}.json

            # Launcher
            makeWrapper ${pkgs.jre}/bin/java $out/bin/minecraft \
                --add-flags "-Djava.library.path='$out/natives'" \
                --add-flags "-cp '$(find $out/libraries -name '*.jar' | tr -s '\n' ':')'" \
                --add-flags "${versionInfo.mainClass}" \
                --add-flags "--version ${versionInfo.id}" \
                --add-flags "--assetsDir $out/assets" \
                --add-flags "--assetIndex ${versionInfo.assets}" \
                --add-flags "--accessToken foobarbaz" \
                --prefix LD_LIBRARY_PATH : "${libPath}"
        '';
    prepareMc = v: rec {
        versionDoc = v;
        versionInfo = if offline
            then builtins.fromJSON (builtins.readFile (./. + "src-${v.id}/${v.id}.json"))
            else builtins.fromJSON (
                    builtins.readFile (
                        builtins.fetchurl { url = versionDoc.url; }));
        assetsIndex = if offline
            then builtins.fromJSON (builtins.readFile (./. + "src-${v.id}/${versionInfo.assets}.json"))
            else builtins.fromJSON (
                    builtins.readFile (
                        builtins.fetchurl { url = versionInfo.assetIndex.url; }));
        client = buildMc versionInfo assetsIndex;
    };
in rec {
    manifest = if offline
        then builtins.fromJSON (builtins.readFile ./version_manifest.json)
        else builtins.fromJSON (
                builtins.readFile (
                    builtins.fetchurl { url = "https://launchermeta.mojang.com/mc/game/version_manifest.json"; }));
    versions = builtins.listToAttrs (map (x: {
        name = "v" + replaceStrings ["."] ["_"] x.id;
        value = prepareMc x;
    }) manifest.versions);
}
