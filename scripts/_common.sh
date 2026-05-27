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

        ynh_print_info "Not ready yet (state: ${unit_state}) — ${waited}/${timeout}s elapsed, retrying in ${interval}s..."
        sleep "$interval"
        waited=$(( waited + interval ))
    done
}
