class Admin::DashboardController < ApplicationController
  layout "admin"
  before_action :require_authentication
  before_action :require_admin!

  def index
    @meetups_count = Meetup.count
    @talks_count = Talk.count
    @next_meetup = Meetup.ordered.first
    @recent_meetups = Meetup.ordered.offset(1).limit(5)
  end
end
