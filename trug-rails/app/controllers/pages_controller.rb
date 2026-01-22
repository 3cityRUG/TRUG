class PagesController < ApplicationController
  allow_unauthenticated_access only: [ :home, :archive ]

  def home
    @next_meetup = Meetup.ordered.first
    @recent_meetups = Meetup.ordered.offset(1).limit(5)
  end

  def archive
    @meetups = Meetup.ordered.includes(:talks)
  end
end
