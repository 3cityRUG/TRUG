require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_one)
  end

  test "should destroy session on logout" do
    sign_in_as(@user)
    delete session_url
    assert_redirected_to root_path
  end

  test "should redirect to root if not authenticated" do
    delete session_url
    assert_redirected_to root_path
  end
end
