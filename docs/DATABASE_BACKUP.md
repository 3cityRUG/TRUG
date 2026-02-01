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

### 3. Install the Cron Job

From your local machine, run the installer which will:
- Create the backup script at `/home/gotar/backup_trug_db.sh` on pi5
- Install a cron job to run it daily at 3:00 AM
- Set up logging to `/var/log/trug-db-backup.log`

```bash
kamal server exec "bash -s" < script/install_backup_cron.sh
```

### 4. Verify Installation

Run the verification script to check everything is set up correctly:

```bash
kamal server exec "bash -s" < script/verify_backup_setup.sh
```

This checks:
- ✓ Backup script exists and is executable
- ✓ Cron job is installed
- ✓ Log file is present
- ✓ GitHub SSH access works
- ✓ Kamal is available
- ✓ Project directory exists

Or manually check:

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
0 3 * * * /home/gotar/backup_trug_db.sh >> /var/log/trug-db-backup.log 2>&1
```

### 5. Test the Backup

Run a manual backup:

```bash
kamal db_backup
```

Or on the server:
```bash
ssh gotar@pi5
/home/gotar/backup_trug_db.sh
```

## How It Works

1. **Host Script** (`script/backup_database.sh`): 
   - Runs on pi5 production server (NOT in container)
   - Uses Kamal to export database from container
   - Compares MD5 hash - only backs up if database changed
   - Creates timestamped backups in `db/backups/`
   - Updates `db/production.sqlite3` (latest)
   - Pushes to `db-backups` branch on GitHub using host SSH keys

2. **Kamal Integration**: 
   - `kamal db_backup` - Run backup manually from local machine
   - Executes `/home/gotar/backup_trug_db.sh` on pi5 server

3. **Cron Job**: 
   - Runs daily at 3:00 AM server time
   - Logs to `/var/log/trug-db-backup.log`

4. **Database Path**:
   - Container: `/rails/storage/production.sqlite3`
   - Host: `/mnt/ssd/trug/production.sqlite3` (volume mount)
   - Script exports from container using `kamal app exec`

## Monitoring

Check backup logs:
```bash
kamal server exec "tail -50 /var/log/trug-db-backup.log"
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

### Kamal Command Not Found
- Script automatically finds Kamal at `/home/gotar/.local/share/gem/ruby/3.2.0/bin/kamal`
- Verify with: `kamal server exec "which kamal"`

### Cron Not Running
- Check crontab: `kamal server exec "crontab -l"`
- Check system time: `kamal server exec "date"`
- View logs: `kamal server exec "tail -100 /var/log/trug-db-backup.log"`
- Check cron logs: `kamal server exec "grep CRON /var/log/syslog | tail -20"`

### Hash File Issues
If backups stop working due to hash comparison:
```bash
kamal server exec "rm /tmp/trug_db_last_hash"
```

## Files

- `script/backup_database.sh` - Host-based backup script (embedded in installer)
- `script/install_backup_cron.sh` - Cron setup script (installs backup on pi5)
- `script/verify_backup_setup.sh` - Verification script (checks setup)
- `config/deploy.yml` - Kamal alias `db_backup`
- `/home/gotar/backup_trug_db.sh` - Installed backup script on pi5 (created by installer)
- `/var/log/trug-db-backup.log` - Backup logs on pi5
