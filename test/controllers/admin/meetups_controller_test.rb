require "test_helper"

class Admin::MeetupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:user_two)
    sign_in_as @admin_user
  end

  test "index action works" do
    get :index
    assert_response :success
  end

  test "new action works" do
    get :new
    assert_response :success
    assert_equal assigns(:meetup).event_type, "formal"
  end

  test "new action with bar type" do
    get :new, params: { type: "bar" }
    assert_response :success
    assert_equal assigns(:meetup).event_type, "bar"
  end

  test "create formal meetup" do
    assert_difference("Meetup.count", 1) do
      post :create, params: {
        meetup: {
          event_type: "formal",
          number: meetups(:one).number + 1,
          date: Date.today + 7.days,
          location: "Test Location"
        }
      }
    end
    assert_redirected_to admin_meetups_path
  end

  test "create bar meetup" do
    assert_difference("Meetup.count", 1) do
      post :create, params: {
        meetup: {
          event_type: "bar",
          date: Date.today + 7.days,
          location: "Test Restaurant"
        }
      }
    end
    assert_redirected_to admin_meetups_path
  end
end
