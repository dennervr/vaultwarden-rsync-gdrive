FROM alpine:latest

# Install dependencies
RUN apk add --no-cache bash curl nodejs npm rclone unzip

# Install Bitwarden CLI globally
RUN npm install -g @bitwarden/cli

# Set working directory
WORKDIR /app

# Copy scripts
COPY backup.sh /app/backup.sh
COPY entrypoint.sh /app/entrypoint.sh

# Permissions
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
