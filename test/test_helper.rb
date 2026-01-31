ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def sign_in_as(user, user_agent: "Test Browser", ip_address: "127.0.0.1")
    session = user.sessions.create!(user_agent: user_agent, ip_address: ip_address)
    cookies.signed[:session_id] = { value: session.id, httponly: true }
    Current.session = session
    Current.user = user
    user
  end

  def sign_out
    cookies.delete(:session_id)
    Current.session = nil
    Current.user = nil
  end
end

class ActionDispatch::IntegrationTest
  def sign_in_as(user, user_agent: "Test Browser", ip_address: "127.0.0.1")
    session = user.sessions.create!(user_agent: user_agent, ip_address: ip_address)
    cookies[:session_id] = { value: session.id, httponly: true }
  end

  def sign_out
    cookies.delete(:session_id)
  end
end
