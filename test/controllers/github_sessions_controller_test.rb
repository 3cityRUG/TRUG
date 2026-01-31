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

  test "should redirect to root with alert when no code provided" do
    get github_session_url
    assert_redirected_to root_path
    assert_equal "Brak kodu autoryzacji.", flash[:alert]
  end

  test "should create user and session from GitHub OAuth callback" do
    skip "Requires mocking Octokit::Client"
  end

  test "should find existing user from GitHub data" do
    skip "Requires mocking Octokit::Client"
  end

  test "should redirect to root after successful GitHub auth" do
    skip "Requires mocking Octokit::Client"
  end
end
