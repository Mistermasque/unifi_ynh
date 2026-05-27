# UniFi Network for YunoHost

[![Integration level](https://dash.yunohost.org/integration/unifi.svg)](https://dash.yunohost.org/appci/app/unifi)
[![Install UniFi Network with YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=unifi)

*[Lire ce README en français](README_fr.md)*

> *This package lets you install UniFi Network quickly and simply on a YunoHost server.
> If you don't have YunoHost, please consult [the guide](https://yunohost.org/install) to learn how to install it.*

## Overview

UniFi Network is the self-hosted network management controller developed by Ubiquiti.
It allows you to centrally manage your entire Ubiquiti network infrastructure — access points,
switches, security gateways, and other UniFi devices — from a single web interface.

**Key features:**

- Unified real-time dashboard for traffic, clients, and device health
- Full wireless management: SSIDs, VLANs, guest networks, and captive portals
- Switch management: VLANs, port profiles, PoE, and link aggregation
- Security gateway: firewall rules, traffic shaping, and VPN support
- Optional guest portal with customisable captive portal
- Optional mobile app speed test
- Built-in scheduled backups of controller configuration
- Seamless zero-handoff client roaming across access points

> **Note:** This package installs the **software controller only**. Ubiquiti hardware
> (access points, switches, gateways…) on your local network is required separately.

**Shipped version:** 8.6.9

**Official website:** <https://ui.com>

**Official admin documentation:** <https://help.ui.com/hc/en-us/articles/220066768>

## Screenshots

![Unifi Network Screenshot](./doc/screenshots/UniFi-OS-3.0-Dashboard.png)

## Requirements

- YunoHost >= 12.0.9
- Architecture: **amd64 only** (Ubiquiti does not publish ARM packages via their APT repository)
- The app must be installed at the **root of a dedicated (sub)domain** — sub-path installs
  (e.g. `example.com/unifi`) are not supported by the application

## Installation

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/unifi_ynh
```

During installation you will be asked:

| Question | Description |
|----------|-------------|
| Domain | The dedicated (sub)domain for the controller (e.g. `unifi.example.com`) |
| Guest portal | Open firewall ports for UniFi's captive guest portal feature |
| Speed test | Open firewall port for the mobile app speed test feature |

After installation, open `https://your-domain/` to complete the **first-run setup wizard**
and create your local admin account.

## Upgrade

```bash
sudo yunohost app upgrade unifi
```

> After a major version upgrade, the controller runs a database migration on first start.
> Wait for the web interface to become available before using it — this can take several minutes.

## Backup and restore

```bash
# Backup
sudo yunohost backup create --apps unifi

# Restore
sudo yunohost backup restore <backup_name> --apps unifi
```

The backup includes the full controller state (`/var/lib/unifi`): network topology, device
records, WiFi/VLAN configuration, and UniFi's own auto-backup archives.

## Documentation

- [Official UniFi documentation](https://help.ui.com/hc/en-us/articles/220066768)
- [YunoHost admin notes for this package](doc/ADMIN.md)

## Contributing

Please send pull requests to the **testing** branch:

```bash
# Install from testing branch
sudo yunohost app install https://github.com/YunoHost-Apps/unifi_ynh/tree/testing --debug

# Upgrade from testing branch
sudo yunohost app upgrade unifi -u https://github.com/YunoHost-Apps/unifi_ynh/tree/testing --debug
```

## License

This YunoHost package is licensed under [AGPL-3.0](LICENSE).

The UniFi Network application itself is proprietary software owned by Ubiquiti Inc.
See [Ubiquiti's EULA](https://www.ui.com/legal/termsofservice/) for its terms of use.
