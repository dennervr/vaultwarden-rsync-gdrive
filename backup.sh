#!/bin/bash

DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="/tmp/bitwarden_backup_${DATE}.json"

echo "[INFO] Starting backup at ${DATE}"

# --- NEW BLOCK ---
# Configure the Bitwarden server before login
if [ -n "$BW_SERVER_URL" ]; then
    echo "[INFO] Setting server to: $BW_SERVER_URL"
    bw config server "$BW_SERVER_URL"
fi
# ------------------

echo "[INFO] Logging into Bitwarden..."
bw login --apikey

echo "[INFO] Unlocking vault..."
export BW_SESSION=$(bw unlock --passwordenv BW_PASSWORD --raw)

echo "[INFO] Syncing..."
bw sync

echo "[INFO] Exporting encrypted vault..."
bw export --format encrypted_json --password "$BACKUP_ENCRYPTION_PASS" --output "$BACKUP_FILE"

echo "[INFO] Uploading to Google Drive..."
rclone copy "$BACKUP_FILE" drive:Backups/Bitwarden

# Cleanup
rm "$BACKUP_FILE"
bw lock
echo "[INFO] Backup completed successfully."
