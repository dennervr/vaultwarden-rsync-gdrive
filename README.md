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

## Run Modes

The container supports two run modes:

- One-shot mode: set `RUN_ONCE=true` to run the backup immediately and have the container exit. Useful for scheduled service runners that call your image at a specific time.
- Cron mode (default): the container runs a Cron scheduler using the `CRON_SCHEDULE` environment variable (cron expression) and keeps running.

Examples:

1. Start a one-shot run via docker-compose or service UI by setting `RUN_ONCE=true`:

```
# Example docker compose env: RUN_ONCE=true
docker compose up --build
```

2. Customize CRON schedule (cron format: `minute hour day month weekday`). For example, to run daily at 02:00 UTC:

```
# Example env: CRON_SCHEDULE="0 2 * * *"
docker compose up -d --build
```

Note: The service UI displays times in UTC. If the service schedule is shown at a certain hour there, set `CRON_SCHEDULE` to the corresponding UTC hour.

## Notes

- Bitwarden server is set via `$BW_SERVER_URL` in [`backup.sh`](backup.sh).
- Ensure your rclone remote `drive` exists in `rclone.conf`.
- Keep `.env` out of source control if publishing publicly.