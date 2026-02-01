# Block bad bots and common vulnerability scanners
class Rack::Attack
  # Safelist localhost for development
  safelist("allow localhost") do |request|
    request.ip == "127.0.0.1" || request.ip == "::1" || request.ip == "localhost"
  end

  # Block requests for common WordPress/PHP vulnerability scanning paths
  BLOCKED_PATHS = %w[
    .php
    wp-login.php
    wp-admin
    wp-content
    wp-includes
    xmlrpc.php
    admin.php
    config.php
    phpmyadmin
    pma
    myadmin
    mysql
    administrator
    admin/login
    admin/admin
    manager
    cms
    wordpress
    drupal
    joomla
    .env
    .git/config
    .git/HEAD
    config.json
    config.xml
    phpinfo.php
    test.php
    info.php
    shell.php
    cmd.php
    backdoor.php
    eval.php
    exec.php
    system.php
    passthru.php
    shell_exec.php
    proc_open.php
    popen.php
    pcntl_exec.php
    assert.php
    preg_replace.php
    create_function.php
    include.php
    require.php
    eval-stdin.php
  ].freeze

  # Block requests matching blocked paths (case insensitive)
  BLOCKED_PATHS.each do |path|
    blocklist("block #{path}") do |request|
      request.path.downcase.include?(path.downcase)
    end
  end

  # Block requests with common bot user agents
  blocklist("block bad bots") do |request|
    user_agent = request.user_agent.to_s.downcase
    [
      "masscan",
      "zgrab",
      "nmap",
      "nikto",
      "sqlmap",
      "dirbuster",
      "gobuster",
      "burp",
      "wfuzz",
      "dirb",
      "crawlergo",
      "x-crawler",
      "scrapy",
      "python-requests",
      "curl",
      "wget",
      "libwww-perl",
      "python-urllib",
      "java/",
      "httpclient",
      "winhttp",
      "httpx",
      "axios",
      "postman",
      "insomnia"
    ].any? { |bot| user_agent.include?(bot) }
  end

  # Throttle general requests by IP (optional but recommended)
  throttle("req/ip", limit: 300, period: 5.minutes) do |request|
    # Skip throttling for assets and session endpoints
    request.ip unless request.path.start_with?("/assets/", "/session")
  end

  # Log blocked requests
  ActiveSupport::Notifications.subscribe(/rack_attack/) do |name, start, finish, request_id, payload|
    if payload[:request]
      Rails.logger.info "[Rack::Attack] Blocked: #{payload[:request].path} from #{payload[:request].ip}"
    end
  end
end
