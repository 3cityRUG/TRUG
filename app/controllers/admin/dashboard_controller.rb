class Admin::DashboardController < ApplicationController
  layout "admin"
  before_action :require_authentication
  before_action :require_admin!

  def index
    @meetups_count = Meetup.count
    @talks_count = Talk.count
    @upcoming_meetups_count = Meetup.upcoming.count
    @average_talks_per_meetup = @meetups_count > 0 ? (@talks_count.to_f / @meetups_count).round(1) : 0
    @next_meetup = Meetup.includes(:talks).upcoming.first
    @recent_meetups = Meetup.includes(:talks).past.limit(5)
  end
end
