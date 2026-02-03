require "test_helper"

class MeetupTest < ActiveSupport::TestCase
  test "validations" do
    meetup = Meetup.new
    assert_not meetup.valid?
    assert meetup.errors[:number].any?
    assert meetup.errors[:date].any?
  end

  test "formal meetup requires number" do
    formal = Meetup.new(event_type: "formal", date: Date.today)
    assert_not formal.valid?
    assert formal.errors[:number].any?
  end

  test "bar meetup does not require number" do
    bar = Meetup.new(event_type: "bar", date: Date.today, location: "Test Restaurant")
    assert bar.valid?
  end

  test "ordered scope returns meetups ordered by event_type and date" do
    result = Meetup.ordered.to_a
    assert_instance_of Array, result
  end

  test "formal scope filters to formal meetups only" do
    result = Meetup.formal
    assert_equal result.to_a, Meetup.where(event_type: "formal").to_a
  end

  test "bar scope filters to bar meetups only" do
    result = Meetup.bar
    assert_equal result.to_a, Meetup.where(event_type: "bar").to_a
  end

  test "archived scope returns only past formal meetups" do
    result = Meetup.archived
    past_formal = Meetup.formal.past
    assert_equal result.to_a, past_formal.to_a
  end

  test "cannot change formal to bar if talks exist" do
    formal = meetups(:one)
    assert formal.talks.any?
    formal.event_type = "bar"
    assert_not formal.valid?
    assert formal.errors[:event_type].any?
  end

  test "number uniqueness" do
    existing = meetups(:one)
    duplicate = Meetup.new(
      number: existing.number,
      date: Date.today,
      location: "Test Location",
      event_type: "formal"
    )
    assert_not duplicate.valid?
    assert duplicate.errors[:number].any?
  end

  test "has many talks" do
    meetup = meetups(:one)
    assert meetup.talks.respond_to?(:each)
    assert_includes meetup.talks.map(&:title), "Open Telemetry w codziennej pracy developera"
  end
end
