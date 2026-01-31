require "test_helper"

class AuthenticationConcernTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_one)
  end

  test "require_authentication redirects to root when not signed in" do
    get admin_root_url
    assert_redirected_to root_path
  end

  test "require_admin! redirects when user not admin" do
    sign_in_as(users(:user_regular))
    get admin_root_url
    assert_redirected_to root_path
  end

  test "signed in user can access authenticated pages" do
    sign_in_as(@user)
    get root_url
    assert_response :success
  end
end
