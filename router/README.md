# Home router: hAP ax lite setup

Step-by-step configuration for the MikroTik hAP ax lite. Paste each block
into WinBox (New Terminal) or an SSH session, one block at a time. The default
factory config is kept (WAN on ether1, LAN bridge `bridge`, 192.168.88.0/24,
default firewall). Everything below only adds to it.

Goals: network-wide ad and tracker blocking through AdGuard DNS, remote access
to the home network with Back To Home, an optional Proton VPN tunnel for chosen
devices, and basic hardening. YouTube on the TV is handled by SmartTube.

## 1. Update RouterOS

Needed for the built-in certificate store (7.19+), which lets DNS-over-HTTPS
verify certificates without importing CA files.

```
/system package update set channel=stable
/system package update check-for-updates
/system package update install
```
The router reboots. Then update the bootloader and reboot again:
```
/system routerboard upgrade
/system reboot
```

## 2. Clock and certificate store

Certificate checks need the right time; these boards have no clock battery.
```
/system ntp client set enabled=yes servers=time.cloudflare.com,pool.ntp.org
/system clock set time-zone-autodetect=yes
/certificate settings print
```
The last command should show `builtin-trust-store: default` with `dns` in
the list. On 7.24 this is already the case and nothing needs setting.

## 3. AdGuard DNS over HTTPS

The router resolves for the whole LAN and forwards everything encrypted to
AdGuard's public filtering servers. The plain servers are only used to look
up the DoH hostname itself.
```
/ip dhcp-client set [find interface=ether1] use-peer-dns=no
/ip dns set servers=94.140.14.14,94.140.15.15 allow-remote-requests=yes \
  use-doh-server=https://dns.adguard-dns.com/dns-query verify-doh-cert=yes
/ip dns cache flush
```
Check: `/ip dns print` shows the DoH server, and `/log print` has no DoH
errors. If the log shows certificate or CRL errors on this small CPU, use
`verify-doh-cert=yes-without-crl`.

## 4. Make every device use the router's DNS

Devices with hardcoded DNS (Chromecast, some TVs) get redirected; DNS over
TLS is blocked so they fall back; Firefox is told not to switch to its own
DoH.
```
/ip firewall nat add chain=dstnat in-interface-list=LAN protocol=udp dst-port=53 \
  action=redirect to-ports=53 comment="force LAN DNS through the router"
/ip firewall nat add chain=dstnat in-interface-list=LAN protocol=tcp dst-port=53 \
  action=redirect to-ports=53 comment="force LAN DNS through the router"
/ip firewall filter add chain=forward in-interface-list=LAN protocol=tcp dst-port=853 \
  action=reject reject-with=tcp-reset comment="block DNS over TLS"
/ip dns static add type=NXDOMAIN name=use-application-dns.net comment="disable Firefox DoH"
```
Optional, Apple devices only: iCloud Private Relay bypasses local DNS for
Safari. To make them fall back to the router (they show a one-time notice):
```
/ip dns static add type=NXDOMAIN name=mask.icloud.com comment="block Private Relay"
/ip dns static add type=NXDOMAIN name=mask-h2.icloud.com comment="block Private Relay"
```
Test from a laptop: `nslookup doubleclick.net 192.168.88.1` should return
0.0.0.0 or no address.

## 5. IPv6 check

```
/ipv6 address print
```
If `bridge` has a global address (starts with `2`), devices can resolve over
IPv6 and skip the filter. Simplest fix until AdGuard Home exists:
```
/ipv6 settings set disable-ipv6=yes
```

## 6. Hardening

Admin password: set it on the web form or over SSH with `/user set admin
password="..."`. Use letters and digits only; `;` and `#` typed unquoted in
the router terminal cut the password short. The 192.168.216.0/24 range below
is the Back To Home tunnel so remote clients can reach the admin page.
```
/ip service disable [find name~"telnet|ftp|api"]
/ip service set winbox address=192.168.88.0/24,192.168.216.0/24
/ip service set ssh address=192.168.88.0/24,192.168.216.0/24
/ip service set www address=192.168.88.0/24,192.168.216.0/24
/ip neighbor discovery-settings set discover-interface-list=LAN
/tool mac-server set allowed-interface-list=LAN
/tool mac-server mac-winbox set allowed-interface-list=LAN
/ip upnp set enabled=no
```

## 7. Fixed addresses and local names (optional)

Give important machines fixed leases and names. Find MACs in
`/ip dhcp-server lease print`.
```
/ip dhcp-server lease add mac-address=XX:XX:XX:XX:XX:XX address=192.168.88.10 \
  server=defconf comment="nixos desktop"
/ip dns static add name=desktop.home.arpa address=192.168.88.10
```

## 8. Remote access: Back To Home

Back To Home is RouterOS's built-in WireGuard server. MikroTik's cloud helps
clients find the router, and if the ISP router blocks direct connections the
traffic goes through a MikroTik relay, so no port forwarding is required.
```
/ip cloud set ddns-enabled=yes ddns-update-interval=10m
/ip cloud set back-to-home-vpn=enabled
/ip cloud back-to-home-user add name=phone allow-lan=yes
/ip cloud back-to-home-user add name=mac allow-lan=yes
/ip cloud print
```
`vpn-status` should be `running` and `vpn-relay-ipv4-status` should report
reachable. In WebFig open IP, Cloud, Back To Home Users and click an entry:
the phone entry shows a QR code for the "MikroTik Back To Home" iOS/Android
app, the mac entry shows a WireGuard configuration for the WireGuard app.

Do not use the shared config printed by `/ip cloud print`; per-user entries
can be revoked individually. iOS runs one VPN at a time, so Tailscale or
Proton must be off on the phone while connected. Test from mobile data.

Troubleshooting: `/interface wireguard peers print detail where
interface=back-to-home-vpn` shows a `last-handshake` per client. A recent
handshake with a page that will not open means a firewall or service
restriction, see the address ranges in step 6.

To get a direct connection instead of the relay, forward UDP 51520 (the
`vpn-port` in `/ip cloud print`) on the ISP router to the hAP's address.

## 9. Proton VPN for chosen devices (optional)

Devices listed in the address list `via-proton` go out through Proton; the
rest and the router itself use the ISP directly, so remote access keeps
working. Create a config at account.protonvpn.com, Downloads, WireGuard
configuration, Platform Router, any server you like. Then, with values from
that file:
```
/interface wireguard add name=wg-proton mtu=1420 private-key="PRIVATE-KEY"
/interface wireguard peers add interface=wg-proton public-key="PEER-PUBLIC-KEY" \
  endpoint-address=ENDPOINT-IP endpoint-port=51820 allowed-address=0.0.0.0/0 \
  persistent-keepalive=25s
/ip address add address=10.2.0.2/30 network=10.2.0.0 interface=wg-proton
/interface list member add list=WAN interface=wg-proton
/routing table add name=via-proton fib
/ip route add dst-address=0.0.0.0/0 gateway=10.2.0.1 routing-table=via-proton
/ip firewall address-list add list=via-proton address=192.168.88.50 comment="example device"
/ip firewall mangle add chain=prerouting in-interface-list=LAN src-address-list=via-proton \
  dst-address=!192.168.88.0/24 connection-state=new action=mark-connection \
  new-connection-mark=proton-conn passthrough=yes comment="proton: mark"
/ip firewall mangle add chain=prerouting in-interface-list=LAN connection-mark=proton-conn \
  action=mark-routing new-routing-mark=via-proton passthrough=no comment="proton: route"
/ip firewall mangle add chain=forward out-interface=wg-proton protocol=tcp tcp-flags=syn \
  action=change-mss new-mss=clamp-to-pmtu passthrough=yes comment="proton: mss"
/ip firewall filter set [find comment="defconf: fasttrack"] connection-mark=no-mark
```
If the file's Address is not 10.2.0.2/32, adjust the address, network and
gateway together. Add `192.168.88.0/24` to the list to send every device
through Proton. Check with `/interface wireguard peers print` (recent
last-handshake) and an IP-check site from a listed device.

## Later: AdGuard Home

No always-on machine exists at home, so filtering uses AdGuard's public DNS.
A small always-on box (Raspberry Pi class) running AdGuard Home would add a
dashboard, per-device stats and custom rules. Once one exists, point the
router at it instead of the public servers:
```
/ip dns set use-doh-server="" servers=192.168.88.10
```
and change the two redirect rules in step 4 to `action=dst-nat
to-addresses=192.168.88.10`. An IoT or guest VLAN with its own Wi-Fi name is
a possible follow-up; it is a larger change and best done at the router with
a cable attached.
