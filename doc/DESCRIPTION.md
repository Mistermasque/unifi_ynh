UniFi Network is the self-hosted network management controller developed by Ubiquiti.
It allows you to centrally manage your entire Ubiquiti network infrastructure — access points,
switches, security gateways, and other UniFi devices — from a single web interface.

### Key features

- **Unified dashboard** — Monitor traffic, connected clients, and device health in real time
- **Wireless management** — Create and manage multiple SSIDs, VLANs, guest networks, and captive portals across all your access points
- **Switch management** — Configure VLANs, port profiles, PoE, and link aggregation on UniFi switches
- **Security gateway** — Firewall rules, traffic shaping, VPN (IPsec, OpenVPN, WireGuard), and threat management
- **Guest portal** — Customisable captive portal with voucher, payment, or social login access (optional)
- **Mobile app** — Full management and speed testing from the UniFi mobile app (optional)
- **Automated backups** — Built-in scheduled backup of the controller configuration
- **Zero-handoff roaming** — Seamless client roaming across access points on the same network

This YunoHost package installs the UniFi Network controller as a systemd service backed by
MongoDB, exposes the web interface via an nginx reverse proxy on your chosen domain, and
integrates the service into the YunoHost admin panel.

> **Note:** This package only installs the **software controller**. You still need Ubiquiti
> hardware (UniFi access points, switches, gateways…) on your local network to manage.
> The controller does not provide Wi-Fi or routing on its own.
