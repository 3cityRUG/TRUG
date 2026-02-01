#!/bin/bash
#
# Verify Database Backup Setup on pi5
#
# Usage: kamal server exec "bash -s" < script/verify_backup_setup.sh
#

set -e

echo "============================================"
echo "Database Backup Setup Verification"
echo "============================================"
echo ""

echo "1. Checking backup script..."
if [ -f "/home/gotar/backup_trug_db.sh" ]; then
    echo "   ✓ Backup script exists"
    if [ -x "/home/gotar/backup_trug_db.sh" ]; then
        echo "   ✓ Script is executable"
    else
        echo "   ✗ Script is NOT executable"
        exit 1
    fi
else
    echo "   ✗ Backup script NOT found at /home/gotar/backup_trug_db.sh"
    exit 1
fi

echo ""
echo "2. Checking cron job..."
if crontab -l 2>/dev/null | grep -q "backup_trug_db"; then
    echo "   ✓ Cron job is installed"
    echo "   Schedule:"
    crontab -l | grep "backup_trug_db"
else
    echo "   ✗ Cron job NOT found"
    exit 1
fi

echo ""
echo "3. Checking log file..."
if [ -f "/var/log/trug-db-backup.log" ]; then
    echo "   ✓ Log file exists"
    LOG_SIZE=$(wc -c < /var/log/trug-db-backup.log)
    echo "   Size: $LOG_SIZE bytes"
    if [ $LOG_SIZE -gt 0 ]; then
        echo "   Last 5 lines:"
        tail -5 /var/log/trug-db-backup.log | sed 's/^/     /'
    fi
else
    echo "   ⚠ Log file not found (will be created on first run)"
fi

echo ""
echo "4. Checking GitHub SSH access..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "   ✓ GitHub SSH authentication works"
else
    echo "   ⚠ GitHub SSH might not be configured"
    echo "   Run: ssh -T git@github.com"
fi

echo ""
echo "5. Checking Kamal..."
KAMAL_BIN="/home/gotar/.local/share/gem/ruby/3.2.0/bin/kamal"
if [ -f "$KAMAL_BIN" ]; then
    echo "   ✓ Kamal found at $KAMAL_BIN"
else
    if which kamal >/dev/null 2>&1; then
        echo "   ✓ Kamal found at $(which kamal)"
    else
        echo "   ✗ Kamal NOT found"
        exit 1
    fi
fi

echo ""
echo "6. Checking project directory..."
if [ -d "/home/gotar/Programowanie/TRUG" ]; then
    echo "   ✓ Project directory exists"
    cd /home/gotar/Programowanie/TRUG
    if [ -f "config/deploy.yml" ]; then
        echo "   ✓ Kamal config found"
    else
        echo "   ✗ Kamal config NOT found"
    fi
else
    echo "   ✗ Project directory NOT found"
    exit 1
fi

echo ""
echo "============================================"
echo "✓ Backup setup verification PASSED"
echo "============================================"
echo ""
echo "You can test the backup now with:"
echo "  /home/gotar/backup_trug_db.sh"
echo ""
echo "Or from local machine:"
echo "  kamal db_backup"
