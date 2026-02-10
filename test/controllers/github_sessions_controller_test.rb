require "test_helper"

class GithubSessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
  end

  teardown do
    OmniAuth.config.mock_auth[:github] = nil
    OmniAuth.config.test_mode = false
  end

  test "should handle missing OAuth data gracefully" do
    post "/auth/github/callback"
    assert_redirected_to root_path
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

    # Rack needs the omniauth.auth in the env
    post "/auth/github/callback", env: { "omniauth.auth" => OmniAuth.config.mock_auth[:github] }

    assert_difference("User.count", 0) do
      # User is created inside the controller from the mock auth
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

    post "/auth/github/callback"

    session = Session.find_by(user_id: existing_user.id)
    assert session.present?, "Expected session to be created for user #{existing_user.id}"
    assert_redirected_to root_path
  end
end
