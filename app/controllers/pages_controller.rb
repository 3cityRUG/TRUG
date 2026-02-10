class PagesController < ApplicationController
  allow_unauthenticated_access only: [ :home, :archive, :rss ]

  def home
    @upcoming_events = [ Meetup.formal.upcoming.first, Meetup.bar.upcoming.first ].compact.sort_by(&:date)
    @recent_meetups = Meetup.formal.ordered.offset(1).limit(5)
  end

  def archive
    @meetups = Meetup.formal.ordered.includes(:talks)
  end

  def rss
    @meetups = Meetup.order(date: :desc).includes(:talks).limit(20)
    @last_modified = Meetup.maximum(:updated_at)
  end
end
