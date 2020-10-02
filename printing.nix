{ pkgs, ... }:
{
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.hplipWithPlugin ];
  };
  services.printing = {
    enable = true;

    browsing = true;
    defaultShared = true;
    listenAddresses = [ "*:631" ];

    drivers = with pkgs; [ pkgs.hplip hplipWithPlugin ];

  };

#  hardware.printers.ensurePrinters = [
#    {
#      name = "HP-LaserJet-MFP-M28-M31";
#      location = "nixos";
#      deviceUri = "hpaio:/usb/HP_LaserJet_MFP_M28-M31?serial=VNC5550653";
#      model = "HP LaserJet MFP m28-m31, hpcups 3.19.12";
#      ppdOptions = {
#        PageSize = "A4";
#      };
#    }
#  ];

}
