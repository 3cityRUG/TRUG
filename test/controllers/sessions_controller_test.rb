require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_one)
    @session = sessions(:session_one)
  end

  test "should destroy session on logout" do
    sign_in_as(@user)
    starting_count = Session.count

    delete session_url

    assert_equal starting_count - 1, Session.count
    assert_redirected_to root_path
    assert_nil cookies[:session_id]
  end

  test "should redirect to root if not authenticated" do
    delete session_url
    assert_redirected_to root_path
  end

  test "should clear current session on logout" do
    sign_in_as(@user)
    created_session = Session.last
    delete session_url

    assert_nil Session.find_by(id: created_session.id)
  end
end
