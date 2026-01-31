require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user with email and password" do
    user = User.new(
      email_address: "new@example.com",
      password: "secure_password"
    )
    assert user.valid?
  end

  test "invalid without email" do
    user = User.new(password: "secure_password")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "can't be blank"
  end

  test "invalid without password" do
    user = User.new(email_address: "test@example.com")
    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end

  test "normalizes email address to lowercase" do
    user = User.create!(
      email_address: "UPPER@EXAMPLE.COM",
      password: "password123"
    )
    assert_equal "upper@example.com", user.email_address
  end

  test "normalizes email address removes whitespace" do
    user = User.create!(
      email_address: "  spaced@example.com  ",
      password: "password123"
    )
    assert_equal "spaced@example.com", user.email_address
  end

  test "from_github creates new user from GitHub data" do
    github_data = {
      "id" => 99999,
      "login" => "newgithubuser",
      "email" => "github@example.com"
    }

    assert_difference("User.count", 1) do
      user = User.from_github(github_data)
      assert_equal "99999", user.github_id
      assert_equal "newgithubuser", user.github_username
      assert_equal "github@example.com", user.email_address
      assert user.github?
    end
  end

  test "from_github finds existing user by github_id" do
    existing_user = users(:user_one)
    github_data = {
      "id" => existing_user.github_id,
      "login" => "different_username",
      "email" => "different@example.com"
    }

    assert_no_difference("User.count") do
      user = User.from_github(github_data)
      assert_equal existing_user.id, user.id
    end
  end

  test "from_github creates user without email if not provided" do
    github_data = {
      "id" => 11111,
      "login" => "noemailuser"
    }

    user = User.from_github(github_data)
    assert_equal "noemailuser@github.local", user.email_address
  end

  test "github? returns true when github_id is present" do
    user = users(:user_one)
    assert user.github?
  end

  test "github? returns false when github_id is nil" do
    user = users(:user_regular)
    assert_not user.github?
  end

  test "has many sessions" do
    user = users(:user_one)
    assert_respond_to user, :sessions
  end

  test "sessions are destroyed when user is destroyed" do
    user = User.create!(
      email_address: "temp@example.com",
      password: "password123"
    )
    user.sessions.create!(user_agent: "Test", ip_address: "127.0.0.1")

    assert_difference("Session.count", -1) do
      user.destroy
    end
  end
end
