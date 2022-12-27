{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSUserEnv {
  name = "arduino";
  targetPkgs = pkgs: (with pkgs; [ 
      arduino
      zlib 
      (python3.withPackages (p: with p; [ pyserial avahi ]))      
    ]);
  runScript = "arduino";
  profile="export _JAVA_AWT_WM_NONREPARENTING=1"; #This fixes odd JRE Rendering issues with the Arduin IDE GUI
}).env
