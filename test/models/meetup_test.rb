require "test_helper"

class MeetupTest < ActiveSupport::TestCase
  test "validations" do
    meetup = Meetup.new
    assert_not meetup.valid?
    assert_includes meetup.errors[:number], "can't be blank"
    assert_includes meetup.errors[:date], "can't be blank"
  end

  test "ordered scope returns meetups in descending date order" do
    meetup1 = meetups(:one)
    meetup2 = meetups(:two)
    assert_equal Meetup.ordered, Meetup.order(date: :desc)
  end

  test "number uniqueness" do
    duplicate_meetup = Meetup.new(
      number: meetups(:one).number,
      date: Date.today,
      location: "Test Location"
    )
    assert_not duplicate_meetup.valid?
    assert_includes duplicate_meetup.errors[:number], "has already been taken"
  end

  test "has many talks" do
    meetup = meetups(:one)
    assert meetup.talks.respond_to?(:each)
    assert_includes meetup.talks.map(&:title), "Open Telemetry w codziennej pracy developera"
  end
end
