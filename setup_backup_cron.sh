#!/bin/bash

# Path to the backup script
SCRIPT_PATH="$(pwd)/db_backup.sh"

# Make the backup script executable
chmod +x ${SCRIPT_PATH}

# Create backup directory with proper permissions
BACKUP_DIR="/Documents/backups"
sudo mkdir -p ${BACKUP_DIR}
sudo chown $(whoami):$(whoami) ${BACKUP_DIR}

# Create a crontab entry for daily backups at 2:00 AM
CRON_ENTRY="0 2 * * * ${SCRIPT_PATH} >> /Documents/backups/cron.log 2>&1"

# Check if the cron job already exists
if crontab -l | grep -q "${SCRIPT_PATH}"; then
    echo "Cron job already exists!"
else
    # Add the new cron job
    (crontab -l 2>/dev/null; echo "${CRON_ENTRY}") | crontab -
    echo "Cron job has been added successfully. Backups will run daily at 2:00 AM."
fi

echo "Backup system setup complete."
echo "Backup script: ${SCRIPT_PATH}"
echo "Backup directory: ${BACKUP_DIR}"
echo "You can edit the backup configuration in the backup script."
echo "To test the backup script immediately, run: ${SCRIPT_PATH}" 