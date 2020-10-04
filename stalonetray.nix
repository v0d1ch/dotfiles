{ config, lib, pkgs, ... }:
with lib;
let cfg = config.services.stalonetray;
in
{
 home.packages = with pkgs; [
    stalonetray
 ];

 services.stalonetray = {
   enable = true;
   config = {
     geometry = "5x1-500+0";
     decorations = null;
     icon_size = 12;
     sticky = true;
     background = "#2E3440";
   };
  };

   systemd.user.services.stalonetray = {
     Unit = {
       Description = "Stalonetray system tray";
       After = [ "graphical-session-pre.target" ];
       PartOf = [ "graphical-session.target" ];
     };

     Install = { WantedBy = [ "graphical-session.target" ]; };

     Service = {
       ExecStart = "${cfg.package}/bin/stalonetray";
       Restart = "on-failure";
     };
   };
}
