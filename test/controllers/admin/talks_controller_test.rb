require "test_helper"

class Admin::TalksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @meetup = meetups(:one)
    @talk = talks(:one)
  end

  def sign_in_as_admin(user)
    sign_in_as(user)
    Admin::TalksController.any_instance.stubs(:admin?).returns(true)
    Admin::TalksController.any_instance.stubs(:require_admin!).returns(nil)
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
    sign_in_as_admin(users(:user_one))

    get new_admin_meetup_talk_url(@meetup)
    assert_response :success
  end

  test "should create talk when admin" do
    sign_in_as_admin(users(:user_one))

    assert_difference("Talk.count") do
      post admin_meetup_talks_url(@meetup), params: {
        talk: {
          title: "New Test Talk",
          speaker_name: "Test Speaker",
          video_id: "abc123",
          video_provider: "youtube"
        }
      }
    end

    assert_redirected_to admin_meetup_url(@meetup)
  end

  test "should get edit when admin" do
    sign_in_as_admin(users(:user_one))

    get edit_admin_talk_url(@talk)
    assert_response :success
  end

  test "should update talk when admin" do
    sign_in_as_admin(users(:user_one))

    patch admin_talk_url(@talk), params: {
      talk: {
        title: "Updated Talk Title"
      }
    }

    assert_redirected_to admin_meetup_url(@meetup)
    assert_equal "Updated Talk Title", @talk.reload.title
  end

  test "should destroy talk when admin" do
    sign_in_as_admin(users(:user_one))

    assert_difference("Talk.count", -1) do
      delete admin_talk_url(@talk)
    end

    assert_redirected_to admin_meetup_url(@meetup)
  end
end
