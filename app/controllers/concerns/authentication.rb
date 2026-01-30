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
    return false unless current_user&.github?
    return true if Rails.env.development?

    token = Rails.application.credentials.github.token
    repo = Rails.application.credentials.github.repo

      client = Octokit::Client.new(access_token: token)
      permission = client.collaborator_permission(repo, current_user.github_username)
      %w[admin write maintain].include?(permission.permission)
    rescue Octokit::Error, Octokit::NotFound
      false
    end

    def require_authentication
      resume_session || request_authentication
    end

    def require_admin!
      unless admin?
        redirect_to root_path, alert: "Nie masz uprawnień administratora."
      end
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def after_authentication_url
      return_to = session.delete(:return_to_after_authenticating)
      return return_to if return_to.present?
      return admin_root_url if admin?

      root_url
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end
end
