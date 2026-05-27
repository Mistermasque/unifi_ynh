## Accessing the controller

The UniFi Network web interface is available at:

```
https://__DOMAIN__/
```

On first access you will be guided through the **initial setup wizard** to create a local
admin account and optionally link the controller to a Ubiquiti cloud account (UI.com).
YunoHost SSO is **not** integrated — UniFi manages its own authentication.

---

## Adopting devices

UniFi devices on the same network are automatically discovered. If your devices are on a
different subnet, set the **controller inform URL** manually on each device:

```
http://__DOMAIN__:8080/inform
```

For devices that need SSH to set the inform URL:

```bash
set-inform http://__DOMAIN__:8080/inform
```

---

## Firewall ports

The following ports are managed by this package:

| Port | Protocol | Purpose | Always open |
|------|----------|---------|-------------|
| 8443 | TCP | Web interface (via nginx reverse proxy) | Yes (nginx only, not direct) |
| 8080 | TCP | Device inform / communication channel | Yes |
| 3478 | UDP | STUN — NAT traversal for devices | Yes |
| 10001 | UDP | Device discovery (broadcast) | Yes |
| 8880 | TCP | Guest portal HTTP redirect | Only if guest portal enabled |
| 8843 | TCP | Guest portal HTTPS redirect | Only if guest portal enabled |
| 6789 | TCP | Mobile app speed test | Only if speed test enabled |

Optional ports (guest portal, speed test) can be toggled at any time from
**YunoHost admin → Apps → UniFi Network → Configuration**.

---

## Data directories

All controller data is stored outside of YunoHost's standard install directory, in paths
managed directly by the `unifi` Debian package:

| Path | Content |
|------|---------|
| `/var/lib/unifi/data/` | MongoDB database, `system.properties`, keystore |
| `/var/lib/unifi/data/backup/` | UniFi's own auto-backup archives (`.unf` files) |
| `/var/log/unifi/` | Application logs (`server.log`, `mongod.log`) |

These paths are included in YunoHost backups automatically when you back up this app.

---

## Backup and restore

This package integrates with the standard YunoHost backup system:

```bash
# Create a backup
yunohost backup create --apps unifi

# Restore from a backup
yunohost backup restore <backup_name> --apps unifi
```

> **Warning:** `/var/lib/unifi` can grow large on networks with many devices or long
> retention of statistics. Check available disk space before performing a backup.

UniFi also maintains its own internal backups under `/var/lib/unifi/data/backup/`.
These `.unf` files can be restored directly from the UniFi web interface independently
of the YunoHost backup system.

---

## Updating UniFi

The UniFi package is installed from Ubiquiti's official APT repository. To update it:

```bash
sudo apt-get update
sudo apt-get install --only-upgrade unifi
```

Or use the standard YunoHost upgrade mechanism:

```bash
yunohost app upgrade unifi
```

> After a major version upgrade (e.g. 8.x → 9.x), the controller will run a **database
> migration** on first start. Do not restart the service during this phase — wait for
> the web interface to become available again (may take several minutes).

---

## JVM memory tuning

UniFi runs on a Java Virtual Machine. The default heap size is 1024 MB. On large
deployments (100+ devices) you may need to increase it via
**YunoHost admin → Apps → UniFi Network → Configuration → Performance**.

For small home deployments you can safely reduce it to 512 MB to free up RAM.

---

## Logs

Service logs are accessible in two ways:

- **YunoHost admin panel** → Services → `unifi` → Logs tab
- From the command line:

```bash
# Application log (UniFi Java process)
tail -f /var/log/unifi/server.log

# MongoDB log
tail -f /var/log/unifi/mongod.log

# systemd journal
journalctl -u unifi -f
```
