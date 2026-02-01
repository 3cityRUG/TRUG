#!/bin/bash
#
# Production Database Backup Setup
# 
# This script installs a cron job on the production server (pi5) that runs daily
# to backup the SQLite database to GitHub.
#
# Usage: kamal server exec "bash -s" < script/install_backup_cron.sh
#

set -e

echo "[DB BACKUP] Installing database backup cron job on pi5..."

BACKUP_SCRIPT='/home/gotar/backup_trug_db.sh'
LOG_FILE='/var/log/trug-db-backup.log'

cat > $BACKUP_SCRIPT << 'BACKUP_SCRIPT_EOF'
#!/bin/bash
#
# Production Database Backup - Runs on pi5 host
#

set -e

REPO_URL="git@github.com:3cityRUG/TRUG.git"
DB_CONTAINER_PATH="/rails/storage/production.sqlite3"
REPO_PATH="/tmp/trug-db-backup-${RANDOM}"
BRANCH="db-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
COMMIT_MSG="backup: production db backup ${TIMESTAMP}"
HASH_FILE="/tmp/trug_db_last_hash"
KAMAL_BIN="/home/gotar/.local/share/gem/ruby/3.2.0/bin/kamal"
PROJECT_DIR="/home/gotar/Programowanie/TRUG"

if [ ! -f "$KAMAL_BIN" ]; then
    KAMAL_BIN=$(which kamal 2>/dev/null || echo "kamal")
fi

echo "[DB BACKUP] Starting backup process..."
echo "[DB BACKUP] Timestamp: $TIMESTAMP"

cd "$PROJECT_DIR"

echo "[DB BACKUP] Calculating database hash..."
CURRENT_HASH=$($KAMAL_BIN app exec --reuse "md5sum $DB_CONTAINER_PATH" 2>/dev/null | awk '{ print $1 }')

if [ -z "$CURRENT_HASH" ]; then
    echo "[DB BACKUP] ERROR: Could not calculate database hash"
    exit 1
fi

echo "[DB BACKUP] Current hash: $CURRENT_HASH"

if [ -f "$HASH_FILE" ]; then
    LAST_HASH=$(cat "$HASH_FILE")
    echo "[DB BACKUP] Last hash: $LAST_HASH"
    
    if [ "$CURRENT_HASH" == "$LAST_HASH" ]; then
        echo "[DB BACKUP] Database unchanged, skipping backup"
        exit 0
    fi
fi

echo "[DB BACKUP] Database changed, proceeding with backup..."

TEMP_DB="/tmp/trug_db_export_${TIMESTAMP}.sqlite3"
echo "[DB BACKUP] Exporting database from container..."
$KAMAL_BIN app exec --reuse "cat $DB_CONTAINER_PATH" > "$TEMP_DB"

if [ ! -f "$TEMP_DB" ]; then
    echo "[DB BACKUP] ERROR: Failed to export database"
    exit 1
fi

echo "[DB BACKUP] Database exported to $TEMP_DB"

echo "[DB BACKUP] Cloning repository..."
rm -rf "$REPO_PATH"
git clone "$REPO_URL" "$REPO_PATH"
cd "$REPO_PATH"

git config user.email "backup@trug.pl"
git config user.name "TRUG Backup Bot"

if git ls-remote --heads origin "$BRANCH" | grep -q "$BRANCH"; then
    echo "[DB BACKUP] Checking out existing branch $BRANCH..."
    git checkout -b "$BRANCH" "origin/$BRANCH"
else
    echo "[DB BACKUP] Creating new branch $BRANCH..."
    git checkout -b "$BRANCH"
fi

mkdir -p db/backups

BACKUP_FILE="db/backups/production_${TIMESTAMP}.sqlite3"
LATEST_FILE="db/production.sqlite3"

cp "$TEMP_DB" "$BACKUP_FILE"
cp "$TEMP_DB" "$LATEST_FILE"
rm -f "$TEMP_DB"

echo "[DB BACKUP] Database copied to $BACKUP_FILE"

git add -A

if git diff --cached --quiet; then
    echo "[DB BACKUP] No changes to commit"
else
    git commit -m "$COMMIT_MSG"
    echo "[DB BACKUP] Committed: $COMMIT_MSG"
    
    echo "[DB BACKUP] Pushing to GitHub..."
    git push origin "$BRANCH"
    echo "[DB BACKUP] Backup pushed successfully!"
fi

cd /
rm -rf "$REPO_PATH"

echo "$CURRENT_HASH" > "$HASH_FILE"
echo "[DB BACKUP] Hash saved for next comparison."

echo "[DB BACKUP] Backup complete!"
BACKUP_SCRIPT_EOF

chmod +x "$BACKUP_SCRIPT"

echo "[DB BACKUP] Created backup script at $BACKUP_SCRIPT"

CRON_LINE="0 3 * * * $BACKUP_SCRIPT >> $LOG_FILE 2>&1"

(crontab -l 2>/dev/null | grep -v "backup_trug_db" | grep -v "trug-db-backup") | crontab -
(crontab -l 2>/dev/null; echo "$CRON_LINE") | crontab -

touch $LOG_FILE
chmod 644 $LOG_FILE

echo "[DB BACKUP] Cron job installed successfully"
echo "[DB BACKUP] Schedule: Daily at 3:00 AM"
echo "[DB BACKUP] Log file: $LOG_FILE"
echo ""
echo "[DB BACKUP] Current crontab:"
crontab -l
echo ""
echo "[DB BACKUP] You can test the backup now with:"
echo "  $BACKUP_SCRIPT"
