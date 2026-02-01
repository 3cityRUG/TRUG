#!/bin/bash
#
# Production Database Backup Setup
# 
# This script installs a cron job on the production server that runs daily
# to backup the SQLite database to GitHub using Kamal.
#
# Usage: kamal server exec "bash -s" < scripts/install_backup_cron.sh
#

set -e

echo "[DB BACKUP] Installing database backup cron job..."

BACKUP_SCRIPT='/home/gotar/backup_trug_db.sh'
LOG_FILE='/var/log/trug-db-backup.log'
KAMAL_BIN='/home/gotar/.local/share/gem/ruby/3.2.0/bin/kamal'

if [ ! -f "$KAMAL_BIN" ]; then
    KAMAL_BIN=$(which kamal 2>/dev/null || echo "kamal")
fi

cat > $BACKUP_SCRIPT << EOF
#!/bin/bash
export SSH_AUTH_SOCK="$SSH_AUTH_SOCK"
cd /home/gotar/Programowanie/TRUG
$KAMAL_BIN app exec --reuse "bundle exec rake db:backup_to_github" 2>&1
EOF

chmod +x $BACKUP_SCRIPT

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
