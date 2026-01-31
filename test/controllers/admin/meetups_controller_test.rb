require "test_helper"

class Admin::MeetupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @meetup = meetups(:one)
  end

  test "should redirect to root when not authenticated" do
    get admin_meetups_url
    assert_redirected_to root_path
  end

  test "should redirect to root when not admin" do
    user = users(:user_regular)
    sign_in_as(user)

    get admin_meetups_url
    assert_redirected_to root_path
  end

  test "should get index when admin" do
    skip "Requires admin authentication"
  end

  test "should get new when admin" do
    skip "Requires admin authentication"
  end

  test "should create meetup when admin" do
    skip "Requires admin authentication"
  end

  test "should get edit when admin" do
    skip "Requires admin authentication"
  end

  test "should update meetup when admin" do
    skip "Requires admin authentication"
  end

  test "should destroy meetup when admin" do
    skip "Requires admin authentication"
  end
end
