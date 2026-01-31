class SessionsController < ApplicationController
  def destroy
    Current.session&.destroy
    cookies.delete(:session_id)
    redirect_to root_path
  end
end
