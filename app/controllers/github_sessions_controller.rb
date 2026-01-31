class GithubSessionsController < ApplicationController
  allow_unauthenticated_access

  def create
    auth = request.env["omniauth.auth"]

    if auth.nil?
      redirect_to root_path, alert: "Nie udało się zalogować przez GitHub."
      return
    end

    github_data = {
      "id" => auth.uid.to_s,
      "login" => auth.info.nickname,
      "email" => auth.info.email
    }

    user = User.from_github(github_data)

    if user.persisted?
      start_new_session_for(user)
      redirect_to root_path, notice: "Zalogowano przez GitHub!"
    else
      redirect_to root_path, alert: "Nie udało się utworzyć konta."
    end
  end

  def failure
    redirect_to root_path, alert: "Nie udało się zalogować przez GitHub."
  end
end
