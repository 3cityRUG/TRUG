require "test_helper"

class Admin::MeetupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @meetup = meetups(:one)
  end

  def sign_in_as_admin(user)
    sign_in_as(user)
    Admin::MeetupsController.any_instance.stubs(:admin?).returns(true)
    Admin::MeetupsController.any_instance.stubs(:require_admin!).returns(nil)
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
    sign_in_as_admin(users(:user_one))

    get admin_meetups_url
    assert_response :success
  end

  test "should get new when admin" do
    sign_in_as_admin(users(:user_one))

    get new_admin_meetup_url
    assert_response :success
  end

  test "should create meetup when admin" do
    sign_in_as_admin(users(:user_one))

    assert_difference("Meetup.count") do
      post admin_meetups_url, params: {
        meetup: {
          number: 999,
          date: Date.current + 1.month,
          description: "Test meetup"
        }
      }
    end

    assert_redirected_to admin_meetup_url(Meetup.last)
  end

  test "should get edit when admin" do
    sign_in_as_admin(users(:user_one))

    get edit_admin_meetup_url(@meetup)
    assert_response :success
  end

  test "should update meetup when admin" do
    sign_in_as_admin(users(:user_one))

    patch admin_meetup_url(@meetup), params: {
      meetup: {
        description: "Updated description"
      }
    }

    assert_redirected_to admin_meetup_url(@meetup)
    assert_equal "Updated description", @meetup.reload.description
  end

  test "should destroy meetup when admin" do
    sign_in_as_admin(users(:user_one))

    assert_difference("Meetup.count", -1) do
      delete admin_meetup_url(@meetup)
    end

    assert_redirected_to admin_meetups_url
  end
end
