class SessionsController < ApplicationController
  def destroy
    terminate_session
    redirect_to root_path, status: :see_other
  end
end
