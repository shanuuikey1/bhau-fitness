#!/bin/bash

# ── BHAU FITNESS — Database Backup & Disaster Recovery Script ────────────────
# This script handles automated backups and restore procedures for both
# local SQL Server (dev) and production PostgreSQL (cloud) environments.

# Exit immediately if a command exits with a non-zero status
set -e

BACKUP_DIR="./Backups"
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "===================================================="
echo "  BHAU FITNESS - Database Backup & Recovery Tool    "
echo "===================================================="

# ── 1. PostgreSQL Backup (Render / Cloud Production) ─────────────────────────
backup_postgres() {
    local db_url=$DATABASE_URL
    if [ -z "$db_url" ]; then
        echo "Error: DATABASE_URL environment variable is not set."
        exit 1
    fi
    
    local backup_file="$BACKUP_DIR/bhau_fitness_pg_$TIMESTAMP.sql"
    echo "Starting PostgreSQL backup..."
    pg_dump "$db_url" -F c -b -v -f "$backup_file"
    echo "Backup completed successfully: $backup_file"
}

restore_postgres() {
    local db_url=$DATABASE_URL
    local backup_file=$1
    
    if [ -z "$db_url" ]; then
        echo "Error: DATABASE_URL environment variable is not set."
        exit 1
    fi
    if [ -z "$backup_file" ] || [ ! -f "$backup_file" ]; then
        echo "Error: Backup file '$backup_file' not found."
        exit 1
    fi
    
    echo "WARNING: This will overwrite the target database. Proceed? (y/n)"
    read -r response
    if [ "$response" != "y" ]; then
        echo "Restore aborted."
        exit 0
    fi
    
    echo "Starting PostgreSQL restore..."
    pg_restore --clean --no-owner -d "$db_url" -v "$backup_file"
    echo "Restore completed successfully!"
}

# ── 2. SQL Server Backup (Local / Docker Development) ────────────────────────
backup_sqlserver() {
    local container_name="bhau-fitness-db-1"
    local backup_file="$BACKUP_DIR/bhau_fitness_mssql_$TIMESTAMP.bak"
    
    echo "Starting SQL Server backup (via Docker container '$container_name')..."
    docker exec -t "$container_name" /opt/mssql-tools/bin/sqlcmd \
        -S localhost -U sa -P "YourStrongPassword123!" \
        -Q "BACKUP DATABASE [BhauFitnessDb] TO DISK = N'/var/opt/mssql/data/BhauFitnessDb_$TIMESTAMP.bak' WITH NOFORMAT, NOINIT, NAME = 'BhauFitnessDb-Full', SKIP, NOREWIND, NOUNLOAD, STATS = 10"
        
    # Copy backup file out of the container to local Backups folder
    docker cp "$container_name:/var/opt/mssql/data/BhauFitnessDb_$TIMESTAMP.bak" "$backup_file"
    echo "Backup copied to host successfully: $backup_file"
}

# ── Command Router ───────────────────────────────────────────────────────────
case "$1" in
    backup-pg)
        backup_postgres
        ;;
    restore-pg)
        restore_postgres "$2"
        ;;
    backup-ms)
        backup_sqlserver
        ;;
    *)
        echo "Usage:"
        echo "  $0 backup-pg          - Backup production PostgreSQL database"
        echo "  $0 restore-pg [file]  - Restore production PostgreSQL database from file"
        echo "  $0 backup-ms          - Backup local SQL Server (Docker)"
        echo ""
        exit 1
        ;;
esac
