# Automated Database Backup to GitHub

Daily automated backup of the production SQLite database to GitHub using a host-based script on pi5.

## Quick Start

### 1. Setup GitHub Access on Production Server

SSH into the production server and configure GitHub access:

```bash
ssh gotar@pi5

# Generate SSH key for GitHub
cd ~
ssh-keygen -t ed25519 -C "backup@trug.pl" -f .ssh/trug_backup -N ""

# Display the public key
cat .ssh/trug_backup.pub
```

Add the public key to GitHub: https://github.com/3cityRUG/TRUG/settings/keys
- Title: "Production DB Backup (pi5)"
- Enable "Allow write access"

Configure SSH to use this key:
```bash
# Add to ~/.ssh/config
cat >> ~/.ssh/config << EOF

Host github.com
  IdentityFile ~/.ssh/trug_backup
  IdentitiesOnly yes
EOF

chmod 600 ~/.ssh/config
```

Test the connection:
```bash
ssh -T git@github.com
```

### 2. Configure Git

```bash
git config --global user.email "backup@trug.pl"
git config --global user.name "TRUG Backup Bot"
```

### 3. Install the Backup Script and Cron Job

Upload the backup script to pi5:

```bash
scp -P 22 script/backup_database.sh gotar@pi5:/home/gotar/backup_trug_db.sh
ssh gotar@pi5 'chmod +x /home/gotar/backup_trug_db.sh'
```

Install the cron job to run daily at 3:00 AM:

```bash
kamal server exec 'CRON_LINE="0 3 * * * /home/gotar/backup_trug_db.sh >> /home/gotar/trug-db-backup.log 2>&1" && (crontab -l 2>/dev/null | grep -v backup_trug; echo "$CRON_LINE") | crontab - && echo "Cron installed"'
```

### 4. Verify Installation

Manually check the installation:

```bash
# Check cron job
kamal server exec "crontab -l"

# Check backup script
kamal server exec "ls -lh /home/gotar/backup_trug_db.sh"

# Check GitHub access
kamal server exec "ssh -T git@github.com"
```

Expected cron output:
```
0 3 * * * /home/gotar/backup_trug_db.sh >> /home/gotar/trug-db-backup.log 2>&1
```

### 5. Test the Backup

Run a manual backup on the server:

```bash
ssh gotar@pi5 '/home/gotar/backup_trug_db.sh'
```

Or via Kamal:
```bash
kamal server exec '/home/gotar/backup_trug_db.sh'
```

## How It Works

1. **Host Script** (`script/backup_database.sh`): 
   - Runs on pi5 production server (NOT in container)
   - Uses Docker directly to export database from container
   - Automatically finds container with name matching `trug-web`
   - Compares MD5 hash - only backs up if database changed
   - Creates timestamped backups in `db/backups/`
   - Updates `db/production.sqlite3` (latest)
   - Pushes to `db-backups` branch on GitHub using host SSH keys

2. **Docker Integration**: 
   - Script finds container: `docker ps --filter "name=trug-web"`
   - Exports DB: `docker exec $CONTAINER cat /rails/storage/production.sqlite3`
   - No Kamal dependency required on pi5

3. **Cron Job**: 
   - Runs daily at 3:00 AM server time
   - Logs to `/home/gotar/trug-db-backup.log`

4. **Database Path**:
   - Container: `/rails/storage/production.sqlite3`
   - Host: `/mnt/ssd/trug/production.sqlite3` (volume mount)
   - Script exports from container using `docker exec`

## Monitoring

Check backup logs:
```bash
kamal server exec "tail -50 /home/gotar/trug-db-backup.log"
```

Check if cron job is installed:
```bash
kamal server exec "crontab -l"
```

View recent backups on GitHub:
```bash
git clone --branch db-backups --single-branch git@github.com:3cityRUG/TRUG.git trug-backups
ls -lh trug-backups/db/backups/
```

## Backup Branch Structure

The `db-backups` branch contains:
```
db/
├── production.sqlite3              # Latest backup
└── backups/
    ├── production_20260201_030000.sqlite3
    ├── production_20260131_030000.sqlite3
    └── ...
```

## Restoring from Backup

To restore the database:

```bash
# 1. Download latest backup from GitHub
cd /tmp
git clone --branch db-backups --single-branch git@github.com:3cityRUG/TRUG.git trug-backup

# 2. Stop the Rails app
kamal app stop

# 3. Backup current database on pi5
ssh gotar@pi5 "cp /mnt/ssd/trug/production.sqlite3 /mnt/ssd/trug/production.sqlite3.bak.$(date +%Y%m%d_%H%M%S)"

# 4. Copy backup to pi5
scp trug-backup/db/production.sqlite3 gotar@pi5:/mnt/ssd/trug/production.sqlite3

# 5. Start the app
kamal app start
```

## Troubleshooting

### Permission Denied (GitHub)
- Verify SSH key is added to GitHub deploy keys with write access
- Check `~/.ssh/config` on pi5 has correct IdentityFile
- Test: `ssh gotar@pi5 "ssh -T git@github.com"`

### Database Not Found
- Check container path: `kamal app exec "ls -la /rails/storage/production.sqlite3"`
- Verify volume mount in `config/deploy.yml`: `/mnt/ssd/trug:/rails/storage`

### Docker Command Not Found
- Script uses Docker at `/usr/bin/docker`
- Verify with: `kamal server exec "which docker"`

### Cron Not Running
- Check crontab: `kamal server exec "crontab -l"`
- Check system time: `kamal server exec "date"`
- View logs: `kamal server exec "tail -100 /home/gotar/trug-db-backup.log"`
- Check cron logs: `kamal server exec "grep CRON /var/log/syslog | tail -20"`

### Hash File Issues
If backups stop working due to hash comparison:
```bash
kamal server exec "rm /tmp/trug_db_last_hash"
```

## Files

- `script/backup_database.sh` - Host-based backup script (uses Docker directly)
- `/home/gotar/backup_trug_db.sh` - Installed backup script on pi5
- `/home/gotar/trug-db-backup.log` - Backup logs on pi5

## Architecture Changes (Feb 2026)

The backup system was simplified to use Docker directly instead of Kamal:

**Before:**
- Required Kamal installed on pi5
- Required TRUG project directory on pi5
- Used `kamal app exec` to export database

**After:**
- Uses Docker directly (`/usr/bin/docker`)
- No pi5 project directory needed
- Finds container by name pattern: `trug-web-*`
- Uses `docker exec` to export database
- Self-contained script with no external dependencies
