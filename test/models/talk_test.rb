require "test_helper"

class TalkTest < ActiveSupport::TestCase
  test "validations" do
    talk = Talk.new
    assert_not talk.valid?
    assert_includes talk.errors[:title], "can't be blank"
    assert_includes talk.errors[:speaker_name], "can't be blank"
  end

  test "belongs to meetup" do
    talk = talks(:one)
    assert talk.meetup.present?
  end
end
