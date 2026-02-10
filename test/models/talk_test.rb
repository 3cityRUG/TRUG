require "test_helper"

class TalkTest < ActiveSupport::TestCase
  test "validations" do
    talk = Talk.new
    assert_not talk.valid?
    assert talk.errors[:title].any?
    assert talk.errors[:speaker_name].any?
  end

  test "belongs to meetup" do
    talk = talks(:one)
    assert talk.meetup.present?
  end
end
