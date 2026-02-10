require "test_helper"

class AttendancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @meetup = meetups(:one)
  end

  test "should redirect to auth when creating attendance without login" do
    post attendances_url, params: {
      attendance: {
        meetup_id: @meetup.id,
        status: "yes"
      }
    }

    assert_redirected_to auth_provider_path(:github)
  end
end
