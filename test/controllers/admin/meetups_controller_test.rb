require "test_helper"

class Admin::MeetupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:user_two)
    sign_in_as @admin_user
  end

  test "index action works" do
    Admin::MeetupsController.any_instance.stubs(:admin?).returns(true)
    get admin_meetups_url
    assert_response :success
  end

  test "new action works" do
    Admin::MeetupsController.any_instance.stubs(:admin?).returns(true)
    get new_admin_meetup_url
    assert_response :success
  end

  test "create meetup" do
    Admin::MeetupsController.any_instance.stubs(:admin?).returns(true)
    assert_difference("Meetup.count", 1) do
      post admin_meetups_url, params: {
        meetup: {
          number: meetups(:one).number + 1,
          date: Date.today + 7.days
        }
      }
    end
    assert_redirected_to admin_meetups_path
  end
end
