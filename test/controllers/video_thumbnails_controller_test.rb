require "test_helper"

class VideoThumbnailsControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to YouTube thumbnail for youtube provider" do
    video_id = "dQw4w9WgXcQ"
    get video_thumbnail_url(id: video_id, provider: "youtube")

    assert_redirected_to "https://img.youtube.com/vi/#{video_id}/sddefault.jpg"
  end

  test "should fetch and redirect to Vimeo thumbnail" do
    video_id = "123456789"
    expected_thumb = "https://i.vimeocdn.com/video/123456789_640.jpg"

    mock_response = Net::HTTPSuccess.new("1.1", "200", "OK")
    mock_response.stub :body, { "thumbnail_url" => expected_thumb }.to_json do
      Net::HTTP.stub :get_response, mock_response do
        get video_thumbnail_url(id: video_id, provider: "vimeo")
        assert_redirected_to expected_thumb
      end
    end
  end

  test "should return not found for vimeo when API fails" do
    video_id = "999999"

    mock_response = Net::HTTPNotFound.new("1.1", "404", "Not Found")
    Net::HTTP.stub :get_response, mock_response do
      get video_thumbnail_url(id: video_id, provider: "vimeo")
      assert_response :not_found
    end
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
