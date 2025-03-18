# Database Backup System

This directory contains scripts for automatically backing up the PostgreSQL database used by the I See Sea application.

## Scripts

1. **db_backup.sh** - This script creates a backup of the PostgreSQL database from within the container and implements a rotation system.

2. **docker_db_backup.sh** - Similar to db_backup.sh but designed to be run from the host machine using docker-compose.

3. **setup_backup_cron.sh** - This script sets up a cron job to automatically run the backup script daily.

## Configuration

The backup configuration is defined at the top of each backup script:

- `BACKUP_DIR`: Directory where backups are stored (default: `/backup/postgres`)
- `MAX_BACKUPS`: Number of backups to keep in rotation (default: 7)
- `DB_USER`, `DB_PASSWORD`, `DB_NAME`: Database connection details

## Setup Instructions

1. Make sure the scripts are executable:
   ```
   chmod +x db_backup.sh docker_db_backup.sh setup_backup_cron.sh
   ```

2. Run the setup script to configure the cron job:
   ```
   ./setup_backup_cron.sh
   ```

3. To test the backup immediately:
   ```
   ./db_backup.sh
   ```
   or for Docker:
   ```
   ./docker_db_backup.sh
   ```

## Backup Rotation

The backup system uses a simple rotation mechanism that:
- Creates timestamped backup files
- Keeps the latest `MAX_BACKUPS` number of backups
- Automatically deletes older backups
- Creates a symbolic link to the latest backup

## Manual Restore (if needed)

To restore from a backup:

```bash
# For direct container access
docker exec -i database psql -U ede7byx74ext7ih -d i_see_sea_prod < /path/to/backup/file.sql

# For Docker Compose
gunzip -c /backup/postgres/latest_backup.sql.gz | docker-compose exec -T database psql -U ede7byx74ext7ih -d i_see_sea_prod
```

## Logging

All backup operations are logged to `/backup/postgres/backup.log` with timestamps.

## Customization

You can adjust the backup frequency by editing the cron job. The default setting performs daily backups at 2:00 AM:

```
0 2 * * * /path/to/db_backup.sh >> /backup/postgres/cron.log 2>&1
``` 