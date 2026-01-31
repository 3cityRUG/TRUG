require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to root when not authenticated" do
    get admin_root_url
    assert_redirected_to root_path
  end

  test "should redirect to root when not admin" do
    user = users(:user_regular)
    sign_in_as(user)

    get admin_root_url
    assert_redirected_to root_path
    assert_equal "Nie masz uprawnień administratora.", flash[:alert]
  end

  test "should get dashboard when admin" do
    skip "Requires admin user setup"
  end
end
