#!/bin/bash

# 1. Configure rclone from the environment variable
# Check if the variable exists
if [ -n "$RCLONE_CONF_BASE64" ]; then
    echo "[INIT] Creating rclone configuration..."
    mkdir -p /root/.config/rclone
    # Decode base64 and save to the file
    echo "$RCLONE_CONF_BASE64" | base64 -d > /root/.config/rclone/rclone.conf
    chmod 600 /root/.config/rclone/rclone.conf
else
    echo "[ERROR] RCLONE_CONF_BASE64 variable not found!"
    exit 1
fi

# 2. Default setup for the backup script
chmod +x /app/backup.sh

# Decide whether to run once and exit, or run scheduled via cron
# If RUN_ONCE is set to "true" (case-insensitive), execute the backup and exit.
if [ -n "$RUN_ONCE" ] && [ "$(echo "$RUN_ONCE" | tr '[:upper:]' '[:lower:]')" = "true" ]; then
    echo "[INIT] RUN_ONCE=true detected — running backup once and exiting..."
    /app/backup.sh
    exit $?
fi

# 3. Configure Cron — allow custom schedule via CRON_SCHEDULE env var (default: midnight UTC)
: "${CRON_SCHEDULE:=0 0 * * *}"
CRON_LINE="$CRON_SCHEDULE /app/backup.sh >> /proc/1/fd/1 2>&1"
echo "$CRON_LINE" > /etc/crontabs/root

# 4. Start Cron in foreground
echo "[INIT] Starting Cron scheduler with schedule: $CRON_SCHEDULE"
crond -f -l 8
