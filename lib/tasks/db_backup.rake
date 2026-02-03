# frozen_string_literal: true

namespace :db do
  desc "Backup production database to GitHub (run via Kamal)"
  task backup_to_github: :environment do
    require "open3"

    # Configuration
    repo_url = "git@github.com:3cityRUG/TRUG.git"
    db_path = Rails.root.join("storage/production.sqlite3").to_s
    repo_path = "/tmp/trug-db-backup-#{SecureRandom.hex(8)}"
    branch = "db-backups"
    timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
    commit_msg = "backup: production db backup #{timestamp}"

    puts "[DB BACKUP] Starting backup process..."
    puts "[DB BACKUP] Database path: #{db_path}"

    # Check if database exists
    unless File.exist?(db_path)
      puts "[DB BACKUP] ERROR: Database not found at #{db_path}"
      exit 1
    end

    # Calculate current database hash
    current_hash = Digest::MD5.file(db_path).hexdigest
    puts "[DB BACKUP] Current database hash: #{current_hash}"

    # Check if database changed using a marker file in tmp
    hash_file = Rails.root.join("tmp/db_backup_last_hash").to_s
    if File.exist?(hash_file)
      last_hash = File.read(hash_file).strip
      puts "[DB BACKUP] Last backup hash: #{last_hash}"

      if current_hash == last_hash
        puts "[DB BACKUP] Database unchanged, skipping backup"
        exit 0
      end
    end

    puts "[DB BACKUP] Database changed, proceeding with backup..."

    begin
      # Clone repository
      puts "[DB BACKUP] Cloning repository..."
      run_command("git clone #{repo_url} #{repo_path}")

      Dir.chdir(repo_path) do
        # Setup git config
        run_command("git config user.email 'backup@trug.pl'")
        run_command("git config user.name 'TRUG Backup Bot'")

        # Check if branch exists on remote
        branch_exists = system("git ls-remote --heads origin #{branch} > /dev/null 2>&1")

        if branch_exists
          puts "[DB BACKUP] Checking out existing branch #{branch}..."
          run_command("git checkout -b #{branch} origin/#{branch}")
        else
          puts "[DB BACKUP] Creating new branch #{branch}..."
          run_command("git checkout -b #{branch}")
        end

        # Create backup directories
        FileUtils.mkdir_p("db/backups")

        # Copy database files
        backup_file = "db/backups/production_#{timestamp}.sqlite3"
        latest_file = "db/production.sqlite3"

        FileUtils.cp(db_path, backup_file)
        FileUtils.cp(db_path, latest_file)
        puts "[DB BACKUP] Database copied to #{backup_file}"

        # Keep only last 5 backups
        all_backups = Dir.glob("db/backups/production_*.sqlite3").sort
        if all_backups.count > 5
          old_backups = all_backups[0...-5]
          old_backups.each do |old|
            File.delete(old)
            puts "[DB BACKUP] Removed old backup: #{File.basename(old)}"
          end
        end

        # Add and commit
        run_command("git add -A")

        # Check if there are changes to commit
        status_output, _ = Open3.capture2("git status --porcelain")
        if status_output.strip.empty?
          puts "[DB BACKUP] No changes to commit"
        else
          run_command("git commit -m '#{commit_msg}'")
          puts "[DB BACKUP] Committed: #{commit_msg}"

          # Push to GitHub
          puts "[DB BACKUP] Pushing to GitHub..."
          run_command("git push origin #{branch}")
          puts "[DB BACKUP] Backup pushed successfully!"
        end
      end

      # Save hash for next run
      File.write(hash_file, current_hash)
      puts "[DB BACKUP] Hash saved for next comparison."

    ensure
      # Cleanup
      if File.directory?(repo_path)
        FileUtils.rm_rf(repo_path)
        puts "[DB BACKUP] Cleaned up temporary files"
      end
    end

    puts "[DB BACKUP] Backup complete!"
  end

  def run_command(cmd)
    stdout, stderr, status = Open3.capture3(cmd)
    unless status.success?
      puts "[DB BACKUP] Command failed: #{cmd}"
      puts "[DB BACKUP] Error: #{stderr}"
      raise "Command failed: #{cmd}"
    end
    stdout
  end
end
