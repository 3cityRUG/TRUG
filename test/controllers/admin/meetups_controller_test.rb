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
    sign_in_as(users(:user_regular))
    get admin_meetups_url
    assert_redirected_to root_path
  end
end
