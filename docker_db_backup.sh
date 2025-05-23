#!/bin/bash

# Configuration
BACKUP_DIR="/Documents/backups"
MAX_BACKUPS=7  # Number of backups to keep (1 week if daily backups)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/i_see_sea_${TIMESTAMP}.sql.gz"
LOG_FILE="${BACKUP_DIR}/backup.log"

# Database connection details from docker-compose.yml
DB_USER="ede7byx74ext7ih"
DB_PASSWORD="IvjPRkjPUX74Tb5"
DB_NAME="i_see_sea_prod"
DB_HOST="localhost"
DB_PORT="5432"

# Make sure backup directory exists
mkdir -p ${BACKUP_DIR}

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a ${LOG_FILE}
}

# Start backup process
log "Starting database backup to ${BACKUP_FILE}"

# Create the backup using docker-compose
docker-compose exec -T database pg_dump -U ${DB_USER} -d ${DB_NAME} | gzip > ${BACKUP_FILE}

# Check if backup was successful
if [ $? -eq 0 ]; then
    log "Backup completed successfully: ${BACKUP_FILE}"
    
    # Set appropriate permissions
    chmod 640 ${BACKUP_FILE}
    
    # Rotate old backups - delete oldest backups if we have more than MAX_BACKUPS
    backup_count=$(ls -1 ${BACKUP_DIR}/i_see_sea_*.sql.gz 2>/dev/null | wc -l)
    if [ ${backup_count} -gt ${MAX_BACKUPS} ]; then
        log "Rotating backups, keeping last ${MAX_BACKUPS}"
        ls -1t ${BACKUP_DIR}/i_see_sea_*.sql.gz | tail -n +$((${MAX_BACKUPS}+1)) | xargs rm -f
        log "Deleted $(($backup_count - ${MAX_BACKUPS})) old backup(s)"
    fi
    
    # Create a symlink to the latest backup
    ln -sf ${BACKUP_FILE} ${BACKUP_DIR}/latest_backup.sql.gz
    log "Created symlink to latest backup"
else
    log "ERROR: Backup failed!"
    exit 1
fi

# Display current backups
log "Current backups:"
ls -lh ${BACKUP_DIR}/i_see_sea_*.sql.gz | tee -a ${LOG_FILE}

log "Backup process completed" 