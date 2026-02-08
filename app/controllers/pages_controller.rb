class PagesController < ApplicationController
  allow_unauthenticated_access only: [ :home, :archive, :rss ]

  def home
    @next_formal_meetup = Meetup.formal.upcoming.first
    @next_bar_meetup = Meetup.bar.upcoming.first
    @recent_meetups = Meetup.formal.ordered.offset(1).limit(5)
  end

  def archive
    @meetups = Meetup.formal.ordered.includes(:talks)
  end

  def rss
    @meetups = Meetup.order(date: :desc).includes(:talks).limit(20)
  end
end
