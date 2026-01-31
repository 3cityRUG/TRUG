require "test_helper"

class AttendancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @meetup = meetups(:one)
  end

  test "should get new attendance form" do
    Meetup.create!(number: 999, date: Date.current + 1.day) unless Meetup.exists?
    get new_attendance_url
    assert_response :success
  end

  test "should redirect to auth when creating attendance without login" do
    post attendances_url, params: {
      attendance: {
        meetup_id: @meetup.id,
        github_username: "newuser",
        status: "yes"
      }
    }

    assert_redirected_to auth_provider_path(:github)
  end

  test "should not create attendance when no meetup exists" do
    Meetup.destroy_all
    post attendances_url, params: {
      attendance: {
        status: "yes"
      }
    }

    assert_response :not_found
  end

  test "should handle turbo stream request by redirecting to auth" do
    post attendances_url, params: {
      attendance: {
        meetup_id: @meetup.id,
        status: "maybe"
      }
    }, as: :turbo_stream

    assert_redirected_to auth_provider_path(:github)
  end
end
