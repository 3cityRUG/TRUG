require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  def mock_admin_check(user)
    Admin::DashboardController.any_instance.stubs(:admin?).returns(true)
    Admin::DashboardController.any_instance.stubs(:require_admin!).returns(nil)
  end

  test "should redirect to root when not authenticated" do
    get admin_root_url
    assert_redirected_to root_path
  end

  test "should redirect to root when not admin" do
    user = users(:user_regular)
    sign_in_as(user)

    get admin_root_url
    assert_redirected_to root_path
  end

  test "should get dashboard when admin" do
    user = users(:user_one)
    sign_in_as(user)
    mock_admin_check(user)

    get admin_root_url
    assert_response :success
  end
end
