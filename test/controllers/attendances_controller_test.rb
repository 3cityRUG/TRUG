require "test_helper"

class AttendancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @meetup = meetups(:one)
  end

  test "should get new attendance form" do
    get new_attendance_url
    assert_response :success
  end

  test "should create attendance" do
    assert_difference("Attendance.count") do
      post attendances_url, params: {
        attendance: {
          meetup_id: @meetup.id,
          github_username: "newuser",
          status: "yes"
        }
      }
    end

    assert_redirected_to root_path
    assert_equal "Dziękujemy za potwierdzenie przybycia!", flash[:notice]
  end

  test "should not create attendance with invalid data" do
    assert_no_difference("Attendance.count") do
      post attendances_url, params: {
        attendance: {
          meetup_id: nil,
          github_username: "",
          status: "yes"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should handle turbo stream request" do
    post attendances_url, params: {
      attendance: {
        meetup_id: @meetup.id,
        github_username: "newuser",
        status: "maybe"
      }
    }, as: :turbo_stream

    assert_response :success
  end
end
