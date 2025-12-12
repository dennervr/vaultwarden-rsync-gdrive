# Bitwarden Backup Automation

Automated encrypted Bitwarden vault backups to Google Drive using Docker, Cron, Bitwarden CLI, and rclone.

## Files

- [Dockerfile](Dockerfile)
- [docker-compose.yml](docker-compose.yml)
- [entrypoint.sh](entrypoint.sh)
- [backup.sh](backup.sh)
- [.env.example](.env.example)

## How it works

- [`entrypoint.sh`](entrypoint.sh) decodes `$RCLONE_CONF_BASE64` into `/root/.config/rclone/rclone.conf`, sets up Cron, and starts it.
- [`backup.sh`](backup.sh) logs into Bitwarden, exports an encrypted backup, and uploads it via rclone to `drive:Backups/Bitwarden`.

## Setup

1. Copy environment example and fill secrets:
```
cp .env.example .env
```
Update:
- `BW_SERVER_URL`
- `BW_CLIENTID`
- `BW_CLIENTSECRET`
- `BW_PASSWORD`
- `BACKUP_ENCRYPTION_PASS`
- `RCLONE_CONF_BASE64` (base64 of your rclone.conf)

Generate rclone config base64:
```
base64 -w 0 ~/.config/rclone/rclone.conf
```

## Build and run

```
docker compose up -d --build
```

The container runs a daily Cron job at midnight. You can also trigger a manual run inside the container:
```
docker exec -it bitwarden-backup /app/backup.sh
```

## Notes

- Bitwarden server is set via `$BW_SERVER_URL` in [`backup.sh`](backup.sh).
- Ensure your rclone remote `drive` exists in `rclone.conf`.
- Keep `.env` out of source control if publishing publicly.