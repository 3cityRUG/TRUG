#!/bin/bash
#
# Production Database Backup - Host-based version
# Runs on production server (pi5) to backup database to GitHub
#

set -e

REPO_URL="git@github.com:3cityRUG/TRUG.git"
DB_CONTAINER_PATH="/rails/storage/production.sqlite3"
REPO_PATH="/tmp/trug-db-backup-${RANDOM}"
BRANCH="db-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
COMMIT_MSG="backup: production db backup ${TIMESTAMP}"
HASH_FILE="/tmp/trug_db_last_hash"
DOCKER_BIN="/usr/bin/docker"
CONTAINER_NAME="trug-web"

echo "[DB BACKUP] Starting backup process..."
echo "[DB BACKUP] Timestamp: $TIMESTAMP"

echo "[DB BACKUP] Finding TRUG container..."
FULL_CONTAINER=$(docker ps --filter "name=${CONTAINER_NAME}" --format "{{.Names}}" | head -1)

if [ -z "$FULL_CONTAINER" ]; then
    echo "[DB BACKUP] ERROR: Could not find container matching ${CONTAINER_NAME}"
    exit 1
fi

echo "[DB BACKUP] Using container: $FULL_CONTAINER"

echo "[DB BACKUP] Calculating database hash..."
CURRENT_HASH=$(docker exec "$FULL_CONTAINER" md5sum "$DB_CONTAINER_PATH" 2>/dev/null | awk '{ print $1 }')

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
docker exec "$FULL_CONTAINER" cat "$DB_CONTAINER_PATH" > "$TEMP_DB"

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
