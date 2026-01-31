require "test_helper"

class GithubSessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
  end

  teardown do
    OmniAuth.config.mock_auth[:github] = nil
    OmniAuth.config.test_mode = false
  end

  test "should handle missing OAuth code gracefully" do
    get "/auth/github/callback"
    assert_response :redirect
  end

  test "should create user and session from GitHub OAuth" do
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: "github",
      uid: "12345",
      info: {
        nickname: "testuser",
        email: "test@example.com"
      }
    )

    assert_difference("User.count", 1) do
      assert_difference("Session.count", 1) do
        post "/auth/github/callback"
      end
    end

    user = User.find_by(github_id: "12345")
    assert_equal "testuser", user.github_username
    assert_redirected_to root_path
  end

  test "should find existing user from GitHub OAuth" do
    existing_user = User.create!(
      email_address: "existing@example.com",
      password: "password123",
      github_id: "12345",
      github_username: "oldusername"
    )

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: "github",
      uid: "12345",
      info: {
        nickname: "testuser",
        email: "test@example.com"
      }
    )

    assert_no_difference("User.count") do
      assert_difference("Session.count", 1) do
        post "/auth/github/callback"
      end
    end

    assert_equal existing_user.id, Session.last.user_id
    assert_redirected_to root_path
  end

  test "should redirect after successful GitHub auth" do
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: "github",
      uid: "12345",
      info: {
        nickname: "testuser",
        email: "test@example.com"
      }
    )

    post "/auth/github/callback"
    assert_redirected_to root_path
  end
end
