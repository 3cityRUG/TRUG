class GithubSessionsController < ApplicationController
  allow_unauthenticated_access only: [ :create, :show ]

  def show
    if params[:code]
      create
    else
      redirect_to root_path, alert: "Brak kodu autoryzacji."
    end
  end

  def create
    github_data = exchange_code_for_token(params[:code])
    Rails.logger.info "GitHub data: #{github_data.inspect}"
    user = User.from_github(github_data)
    Rails.logger.info "User created: #{user.inspect}"
    start_new_session_for user
    redirect_to after_authentication_url
  end

  private

  def exchange_code_for_token(code)
    client_id = ENV.fetch("GITHUB_CLIENT_ID")
    client_secret = ENV.fetch("GITHUB_CLIENT_SECRET")

    response = Faraday.post("https://github.com/login/oauth/access_token") do |req|
      req.headers["Accept"] = "application/json"
      req.headers["User-Agent"] = "TRUG Rails"
      req.body = URI.encode_www_form(
        client_id: client_id,
        client_secret: client_secret,
        code: code
      )
    end

    token_response = JSON.parse(response.body)

    if token_response["error"]
      raise token_response["error_description"]
    end

    access_token = token_response["access_token"]
    Rails.logger.info "Got access token: #{access_token&.slice(0, 10)}..."

    client = Octokit::Client.new(access_token: access_token)
    user_data = client.user
    Rails.logger.info "GitHub user: #{user_data.login}, ID: #{user_data.id}, email: #{user_data.email}"

    { "id" => user_data.id.to_s, "login" => user_data.login, "email" => user_data.email }
  end
end
