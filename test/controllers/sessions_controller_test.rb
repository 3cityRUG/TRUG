require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_one)
    @session = sessions(:session_one)
  end

  test "should destroy session on logout" do
    # Sign in the user first
    post session_url, params: { session: { email: @user.email_address, password: "password" } }, headers: { "HTTP_USER_AGENT" => "Test Browser" }

    assert_difference("Session.count", -1) do
      delete session_url
    end

    assert_redirected_to root_path
    assert_nil cookies[:session_id]
  end

  test "should redirect to root if not authenticated" do
    delete session_url
    assert_redirected_to root_path
  end

  test "should clear current session on logout" do
    # Sign in
    post session_url, params: { session: { email: @user.email_address, password: "password" } }

    # Sign out
    delete session_url

    assert_nil Session.find_by(id: @session.id)
  end
end
