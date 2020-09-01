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

    drivers = with pkgs; [ hplip ];

    extraConf = ''
        <Location />
          Order allow,deny
          Allow localhost
          Allow @LOCAL
        </Location>

        <Policy default>
          <Limit Hold-Job Release-Job Restart-Job Purge-Jobs Set-Job-Attributes Create-Job-Subscription Renew-Subscription Cancel-Subscription Get-Notifications Reprocess-Job Cancel-Current-Job Suspend-Current-Job Resume-Job CUPS-Move-Job>
            Require user @OWNER @SYSTEM
            Order deny,allow
          </Limit>

          <Limit Pause-Printer Resume-Printer Set-Printer-Attributes Enable-Printer Disable-Printer Pause-Printer-After-Current-Job Hold-New-Jobs Release-Held-New-Jobs Deactivate-Printer Activate-Printer Restart-Printer Shutdown-Printer Startup-Printer Promote-Job Schedule-Job-After CUPS-Add-Printer CUPS-Delete-Printer CUPS-Add-Class CUPS-Delete-Class CUPS-Accept-Jobs CUPS-Reject-Jobs CUPS-Set-Default>
            AuthType Basic
            Require user @SYSTEM
            Order deny,allow
          </Limit>

          <Limit Cancel-Job CUPS-Authenticate-Job>
            Require user @OWNER @SYSTEM
            Order deny,allow
          </Limit>

          <Limit All>
            Order deny,allow
          </Limit>
        </Policy>
      '';
  };

  hardware.printers.ensurePrinters = [
    {
      name = "HP-LaserJet-MFP-M28-M31";
      location = "nixos";
      deviceUri = "hp:/usb/HP_LaserJet_MFP_M28-M31?serial=VNC5550653";
      model = "HP LaserJet MFP m28-m31, hpcups 3.19.12";
      ppdOptions = {
        PageSize = "A4";
      };
    }
  ];

}
