require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to root when not authenticated" do
    get admin_root_url
    assert_redirected_to root_path
  end

  test "should redirect to root when not admin" do
    sign_in_as(users(:user_regular))
    get admin_root_url
    assert_redirected_to root_path
  end
end
