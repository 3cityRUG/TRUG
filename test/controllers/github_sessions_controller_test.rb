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
      uid: "99999",
      info: {
        nickname: "newuser",
        email: "newuser@example.com"
      }
    )

    assert_difference("User.count", 1) do
      assert_difference("Session.count", 1) do
        post "/auth/github/callback"
      end
    end

    user = User.find_by(github_id: "99999")
    assert_equal "newuser", user.github_username
    assert_redirected_to root_path
  end

  test "should find existing user from GitHub OAuth" do
    existing_user = User.create!(
      email_address: "existing@example.com",
      password: "password123",
      github_id: "88888",
      github_username: "oldusername"
    )

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: "github",
      uid: "88888",
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
      uid: "77777",
      info: {
        nickname: "testuser2",
        email: "test2@example.com"
      }
    )

    post "/auth/github/callback"
    assert_redirected_to root_path
  end
end
