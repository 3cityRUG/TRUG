require "test_helper"

class GithubSessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @github_auth_code = "test_auth_code"
    @github_token = "test_access_token"
    @github_user_data = {
      "id" => 12345,
      "login" => "testuser",
      "email" => "test@example.com"
    }
  end

  def mock_omniauth_auth
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      provider: "github",
      uid: "12345",
      info: {
        nickname: "testuser",
        email: "test@example.com"
      }
    })
  end

  def clear_omniauth_mock
    OmniAuth.config.mock_auth[:github] = nil
  end

  test "should handle missing OAuth code" do
    get auth_github_callback_url
    assert_response :redirect
  end

  test "should create user and session from GitHub OAuth callback" do
    mock_omniauth_auth

    assert_difference("User.count", 1) do
      assert_difference("Session.count", 1) do
        post auth_github_callback_url
      end
    end

    user = User.find_by(github_id: "12345")
    assert_equal "testuser", user.github_username
    assert_equal "test@example.com", user.email_address
    assert_redirected_to root_path
    assert_equal "Zalogowano przez GitHub!", flash[:notice]

    clear_omniauth_mock
  end

  test "should find existing user from GitHub data" do
    existing_user = User.create!(
      email_address: "existing@example.com",
      password: "password123",
      github_id: "12345",
      github_username: "oldusername"
    )

    mock_omniauth_auth

    assert_no_difference("User.count") do
      assert_difference("Session.count", 1) do
        post auth_github_callback_url
      end
    end

    assert_equal existing_user.id, Session.last.user_id
    assert_redirected_to root_path

    clear_omniauth_mock
  end

  test "should redirect to root after successful GitHub auth" do
    mock_omniauth_auth

    post auth_github_callback_url

    assert_redirected_to root_path
    assert_equal "Zalogowano przez GitHub!", flash[:notice]

    clear_omniauth_mock
  end

  test "should handle OmniAuth failure" do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:github] = :invalid_credentials

    get auth_failure_url

    assert_redirected_to root_path
    assert_equal "Nie udało się zalogować przez GitHub.", flash[:alert]

    OmniAuth.config.mock_auth[:github] = nil
  end
end
