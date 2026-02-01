module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
    helper_method :current_user
    helper_method :admin?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def current_user
      Current.session&.user
    end

    def admin?
      Rails.logger.info "[ADMIN CHECK] Starting admin check for user: #{current_user&.github_username}"

      unless current_user
        Rails.logger.info "[ADMIN CHECK] FAILED: No current_user"
        return false
      end

      unless current_user.github?
        Rails.logger.info "[ADMIN CHECK] FAILED: User #{current_user.github_username} has no github_id"
        return false
      end

      return true if Rails.env.development?

      # Check against hardcoded list of known admins (bypass API for owners)
      hardcoded_admins = [ "gotar" ]
      if hardcoded_admins.include?(current_user.github_username.downcase)
        Rails.logger.info "[ADMIN CHECK] PASSED: User is in hardcoded admin list"
        return true
      end

      token = Rails.application.credentials.github.token
      repo = Rails.application.credentials.github.repo

      # Skip API check if token is the placeholder
      if token == "ghp_development_test_token"
        Rails.logger.error "[ADMIN CHECK] ERROR: GitHub token is placeholder. Set a real token in credentials."
        return false
      end

      Rails.logger.info "[ADMIN CHECK] Checking GitHub access for #{current_user.github_username} on repo #{repo}"

      client = Octokit::Client.new(access_token: token)

      # Check collaborator status (includes admins, maintainers, writers)
      is_collaborator = client.collaborator?(repo, current_user.github_username)
      Rails.logger.info "[ADMIN CHECK] collaborator? result: #{is_collaborator}"
      return true if is_collaborator

      # Also check if user is the repo owner (owner is not a "collaborator")
      repo_info = client.repo(repo)
      owner_match = repo_info.owner.login.downcase == current_user.github_username.downcase
      Rails.logger.info "[ADMIN CHECK] owner check: repo_owner=#{repo_info.owner.login}, user=#{current_user.github_username}, match=#{owner_match}"
      return true if owner_match

      Rails.logger.info "[ADMIN CHECK] FAILED: User is neither collaborator nor owner"
      false
    rescue Octokit::Error, Octokit::NotFound => e
      Rails.logger.error "[ADMIN CHECK] ERROR: #{e.class}: #{e.message}"
      false
    end

    def require_admin!
      unless admin?
        redirect_to root_path, alert: "Nie masz uprawnień administratora."
      end
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie

      # Development bypass - auto-authenticate as admin
      # Skip if user explicitly logged out
      if Rails.env.development? && Current.session.nil? && !session[:skip_auto_login]
        dev_user = User.find_or_create_by!(github_username: "dev_admin") do |u|
          u.github_id = "999999"
          u.email_address = "dev@localhost"
          u.password = SecureRandom.hex(32)
        end
        Current.session = dev_user.sessions.create!
        cookies.signed[:session_id] = { value: Current.session.id, httponly: true }
      end

      Current.session
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to root_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def start_new_session_for(user)
      Current.session = user.sessions.create!
      cookies.signed[:session_id] = { value: Current.session.id, httponly: true, secure: Rails.env.production? }
    end

    def terminate_session
      Current.session&.destroy
      cookies.delete(:session_id)
    end
end
