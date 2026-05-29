#!/bin/bash

# =============================================================================
# _common.sh — Shared helpers for all UniFi YunoHost scripts
#
# Sourced by every script via:  source _common.sh
# Must be sourced BEFORE /usr/share/yunohost/helpers so that any
# overrides here take precedence if needed.
# =============================================================================

# -----------------------------------------------------------------------------
# ynh_unifi_wait_until_active
#
# Polls `systemctl is-active unifi` until the unit reaches the "active"
# state, then returns 0. Aborts with ynh_die on a hard failure or timeout.
#
# Usage:
#   ynh_unifi_wait_until_active
#
# Optional environment overrides (set before calling if needed):
#   UNIFI_WAIT_TIMEOUT   — max seconds to wait            (default: 300)
#   UNIFI_WAIT_INTERVAL  — seconds between each poll      (default: 5)
#
# Context: UniFi runs a JVM + MongoDB. On first boot or after a major
# upgrade a database migration runs before the HTTP listener starts.
# On modest hardware this can take 2-3 minutes. 300 s (5 min) is generous
# enough for slow hardware while still failing visibly if something breaks.
# -----------------------------------------------------------------------------
ynh_unifi_wait_until_active() {
    local timeout="${UNIFI_WAIT_TIMEOUT:-300}"
    local interval="${UNIFI_WAIT_INTERVAL:-5}"
    local waited=0
    local unit_state

    ynh_print_info "Waiting for UniFi service to become active (timeout: ${timeout}s)..."

    while true; do
        if systemctl is-active --quiet unifi; then
            ynh_print_info "UniFi service is active."
            return 0
        fi

        unit_state=$(systemctl is-active unifi 2>/dev/null || echo "unknown")

        # Hard failure — don't waste the full timeout
        if [ "$unit_state" = "failed" ]; then
            ynh_die "UniFi service entered a failed state. Check the logs with: journalctl -u unifi --no-pager -n 50"
        fi

        if [ "$waited" -ge "$timeout" ]; then
            ynh_die "UniFi service did not become active within ${timeout}s (current state: ${unit_state}). Check the logs with: journalctl -u unifi --no-pager -n 50"
        fi

        sleep "$interval"
        waited=$(( waited + interval ))
    done
}


#=================================================
# OPEN FIREWALL PORTS
#=================================================
# Port 8443 is reverse-proxied by nginx — do NOT expose it directly.
#
# Always-required ports for device <-> controller communication:
#   UDP 3478   STUN — NAT traversal for APs / switches
#   TCP 8080   Inform channel — devices phone home to the controller
#   UDP 10001  Device discovery (L2/L3 broadcast)
#
# Conditionally-required ports driven by install questions:
#   TCP 8880   HTTP  guest-portal redirect  ($guest_portal)
#   TCP 8843   HTTPS guest-portal redirect  ($guest_portal)
#   TCP 6789   Mobile speed test            ($speed_test)
# If more port needed : https://help.ui.com/hc/en-us/articles/218506997-Required-Ports-Reference
#=================================================
ynh_unifi_open_ports() {
    ynh_print_info "Opening required firewall ports..."

    # Required ports (always opened)
    ynh_hide_warnings yunohost firewall open 3478 "Unifi STUN (Session Traversal Utilities for NAT)" -p udp
    ynh_hide_warnings yunohost firewall open 8080 "Unifi device management traffic" -p tcp
    ynh_hide_warnings yunohost firewall open 10001 "Unifi device discovery" -p udp

    # Optionnal ports

    ynh_print_info "Create guest portal firewall ports rules (8880, 8843)..."
    ynh_hide_warnings yunohost firewall open 8880 "Unifi Hotspot portail redirection (HTTP)" -p tcp
    ynh_hide_warnings yunohost firewall open 8843 "Unifi Hotspot portail redirection (HTTPS)" -p tcp
    # Close thoses ports if not used (but will be still present in yunohost firewall config)
    if [ "$guest_portal" -eq 0 ]; then
        ynh_hide_warnings yunohost firewall disallow TCP 8880
        ynh_hide_warnings yunohost firewall disallow TCP 8843
    fi

    ynh_print_info "Create speed test firewall port rules (6789)..."
    ynh_hide_warnings yunohost firewall open 6789 "Unifi mobile speed test" -p tcp
    # Close thoses ports if not used (but will be still present in yunohost firewall config)
    if [ "$speed_test" -eq 0 ]; then
        ynh_hide_warnings yunohost firewall disallow TCP 6789
    fi

}

#=================================================
# CLOSE FIREWALL PORTS
#=================================================
# Close every port that was opened during install.
# We use "|| true" on every call so that a port that was never opened
# (e.g. guest_portal=0 at install time) does not abort the script.
#
# Core ports — always close them regardless of settings, because they
# are always opened unconditionally in the install script.
#=================================================
ynh_unifi_close_ports() {
    ynh_print_info "Closing firewall ports..."

    ynh_hide_warnings yunohost firewall delete 3478 -p udp  || true
    ynh_hide_warnings yunohost firewall delete 8080 -p tcp  || true
    ynh_hide_warnings yunohost firewall delete 10001 -p udp || true

    # Guest portal ports — only close if the feature was enabled at install
    # (or later toggled on via the config panel). We try regardless with
    # "|| true" so a misconfigured state never blocks removal.
    if [ "${guest_portal:-0}" -eq 1 ]; then
        ynh_print_info "Closing guest portal firewall ports (8880, 8843)..."
    fi
    ynh_hide_warnings yunohost firewall delete 8880 -p tcp  || true
    ynh_hide_warnings yunohost firewall delete 8843 -p tcp  || true

    # Speed test port — same pattern
    if [ "${speed_test:-0}" -eq 1 ]; then
        ynh_print_info "Closing speed test firewall port (6789)..."
    fi
    ynh_hide_warnings yunohost firewall delete 6789 -p tcp  || true
}
