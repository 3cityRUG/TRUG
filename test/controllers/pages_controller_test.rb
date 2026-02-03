require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "GET / returns success" do
    get root_url
    assert_response :success
  end

  test "GET / returns correct content type" do
    get root_url
    assert_match "text/html", response.content_type
  end

  test "GET /archive returns success" do
    get archive_url
    assert_response :success
  end

  test "home action sets next formal meetup" do
    get :home
    assert_response :success
    assert_not_nil assigns(:next_formal_meetup)
  end

  test "home action sets next bar meetup" do
    get :home
    assert_response :success
    assert_not_nil assigns(:next_bar_meetup)
  end

  test "archive action filters to formal" do
    get :archive
    assert_response :success
    meetups = assigns(:meetups)
    assert meetups.respond_to?(:each)
  end
end
