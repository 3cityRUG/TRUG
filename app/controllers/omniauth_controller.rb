class OmniauthController < ApplicationController
  def passthru
    redirect_to root_path, alert: "Authentication error."
  end
end
