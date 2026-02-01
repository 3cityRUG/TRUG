# Automated Database Backup to GitHub

Daily automated backup of the production SQLite database to GitHub using Kamal.

## Quick Start

### 1. Setup GitHub Access on Production Server

SSH into the production server and configure GitHub access:

```bash
kamal server exec

# Generate SSH key for GitHub
cd ~
ssh-keygen -t ed25519 -C "backup@trug.pl" -f .ssh/trug_backup -N ""

# Display the public key
cat .ssh/trug_backup.pub
```

Add the public key to GitHub: https://github.com/3cityRUG/TRUG/settings/keys
- Title: "Production DB Backup"
- Enable "Allow write access"

Test the connection:
```bash
ssh -i ~/.ssh/trug_backup -T git@github.com
```

### 2. Configure Git

```bash
kamal server exec

git config --global user.email "backup@trug.pl"
git config --global user.name "TRUG Backup Bot"
```

### 3. Install the Cron Job

From your local machine:

```bash
kamal server exec "bash -s" < scripts/install_backup_cron.sh
```

This creates:
- Backup script at `/home/gotar/backup_trug_db.sh`
- Cron job running daily at 3:00 AM
- Log file at `/var/log/trug-db-backup.log`

### 4. Test the Backup

Run a manual backup:

```bash
kamal db_backup
```

Or on the server:
```bash
kamal server exec "bash /home/gotar/backup_trug_db.sh"
```

## How It Works

1. **Rake Task** (`lib/tasks/db_backup.rake`): Compares MD5 hash of database
   - Only backs up if database changed
   - Creates timestamped backups in `db/backups/`
   - Updates `db/production.sqlite3` (latest)
   - Pushes to `db-backups` branch on GitHub

2. **Kamal Integration**: 
   - `kamal db_backup` - Run backup manually
   - Runs inside the Rails container via `kamal app exec`

3. **Cron Job**: 
   - Runs daily at 3:00 AM server time
   - Logs to `/var/log/trug-db-backup.log`

## Monitoring

Check backup logs:
```bash
kamal server exec "tail -50 /var/log/trug-db-backup.log"
```

Check if cron job is installed:
```bash
kamal server exec "crontab -l"
```

## Backup Branch Structure

The `db-backups` branch contains:
```
db/
├── production.sqlite3              # Latest backup
└── backups/
    ├── production_20260131_030000.sqlite3
    ├── production_20260130_030000.sqlite3
    └── ...
```

## Restoring from Backup

To restore the database:

```bash
# Access production server
kamal server exec

# Stop the Rails app
kamal stop

# Backup current database
cp /mnt/ssd/trug/production.sqlite3 /mnt/ssd/trug/production.sqlite3.bak.$(date +%Y%m%d)

# Download latest backup
cd /tmp
git clone --branch db-backups --single-branch git@github.com:3cityRUG/TRUG.git trug-backup

# Restore
cp trug-backup/db/production.sqlite3 /mnt/ssd/trug/production.sqlite3

# Start the app
kamal start
```

## Troubleshooting

### Permission Denied (GitHub)
- Verify SSH key is added to GitHub deploy keys
- Test: `ssh -i ~/.ssh/trug_backup -T git@github.com`

### Database Not Found
- Check path in container: `kamal app exec "ls -la storage/production.sqlite3"`
- Verify volume mount in `config/deploy.yml`

### Cron Not Running
- Check crontab: `kamal server exec "crontab -l"`
- Check system time: `kamal server exec "date"`
- View system logs: `kamal server exec "tail /var/log/syslog"`

## Files

- `lib/tasks/db_backup.rake` - Backup rake task
- `scripts/install_backup_cron.sh` - Cron setup script
- `config/deploy.yml` - Kamal alias `db_backup` added
