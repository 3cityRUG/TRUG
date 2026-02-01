class SessionsController < ApplicationController
  def destroy
    Current.session&.destroy
    cookies.delete(:session_id)
    # Prevent auto-login after explicit logout
    session[:skip_auto_login] = true
    redirect_to root_path
  end
end
