require "test_helper"

class VideoThumbnailsControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to YouTube thumbnail for youtube provider" do
    video_id = "dQw4w9WgXcQ"
    get video_thumbnail_url(id: video_id, provider: "youtube")

    assert_redirected_to "https://img.youtube.com/vi/#{video_id}/sddefault.jpg"
  end

  test "should return not found for vimeo without API access" do
    skip "Requires mocking external API call to Vimeo oEmbed"
  end

  test "should return not found for invalid provider" do
    get video_thumbnail_url(id: "12345", provider: "invalid")
    assert_response :not_found
  end

  test "should return not found for blank video id" do
    get video_thumbnail_url(id: "", provider: "youtube")
    assert_response :not_found
  end
end
