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
    user = users(:user_regular)
    sign_in_as(user)

    get new_admin_meetup_talk_url(@meetup)
    assert_redirected_to root_path
  end

  test "should get new when admin" do
    skip "Requires admin authentication"
  end

  test "should create talk when admin" do
    skip "Requires admin authentication"
  end

  test "should get edit when admin" do
    skip "Requires admin authentication"
  end

  test "should update talk when admin" do
    skip "Requires admin authentication"
  end

  test "should destroy talk when admin" do
    skip "Requires admin authentication"
  end
end
