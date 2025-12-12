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

# 3. Configure Cron
echo "0 0 * * * /app/backup.sh >> /proc/1/fd/1 2>&1" > /etc/crontabs/root

# 4. Inicia o Cron
echo "[INIT] Starting Cron scheduler..."
crond -f -l 8
