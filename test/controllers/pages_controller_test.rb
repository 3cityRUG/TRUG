require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "GET / returns success" do
    get root_url
    assert_response :success
  end

  test "GET /archive returns success" do
    get archive_url
    assert_response :success
  end
end
