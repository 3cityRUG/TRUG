require "test_helper"

class Admin::TalksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @meetup = meetups(:one)
    @talk = talks(:one)
  end

  test "should redirect to root when not authenticated" do
    get new_admin_meetup_talk_url(@meetup)
    assert_redirected_to root_path
  end

  test "should redirect to root when not admin" do
    sign_in_as(users(:user_regular))
    get new_admin_meetup_talk_url(@meetup)
    assert_redirected_to root_path
  end
end
