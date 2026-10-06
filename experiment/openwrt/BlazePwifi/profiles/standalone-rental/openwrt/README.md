# OpenWrt Rental Standalone — v0.5.2-rental-rc.1

The installer is intentionally **network-neutral**. It does not change WAN, LAN, Wi-Fi, cellular, repeater, DNS, or firewall UCI configuration during Standalone installation.

After installation:

- existing router/basic UI stays where the device already provides it;
- BlazePwifi Rental management is added at `https://LocalIP/rental/`;
- BlazeRental phones use `http://LocalIP`;
- authenticated remote ESP coinslot interfaces use `http://LocalIP:4455/cgi-bin/vendo`.

## R281 / EasyMode path

When the Windows OneClick installer detects `/tmp/sysinfo/board_name = notion,r281`, it automatically runs `install-r281.sh`.

That R281-specific entry verifies:

- OpenWrt 24.10.x;
- uHTTPd home `/www`;
- CGI prefix `/cgi-bin`;
- existing HTTPS :443.

The Windows deployer extracts the bundle with plain BusyBox-supported `tar -xzf ... -C ...` and then enters the archive's single top-level directory. No GNU-only archive options are used.

## Full conversion

The complete BlazePwifi payload remains installed but the hotspot core stays disabled. Conversion to full BlazePwifi is explicit:

```sh
/usr/sbin/blazepwifi-rental-upgrade --full
```

Only that conversion step may activate BlazePwifi hotspot/firewall ownership.
