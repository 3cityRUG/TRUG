class VideoThumbnailsController < ApplicationController
  allow_unauthenticated_access

  def show
    video_id = params[:id]
    provider = params[:provider]

    if provider == "vimeo"
      thumbnail = fetch_vimeo_thumbnail(video_id)
    elsif provider == "youtube"
      thumbnail = "https://img.youtube.com/vi/#{video_id}/sddefault.jpg"
    end

    if thumbnail
      redirect_to thumbnail, allow_other_host: true
    else
      head :not_found
    end
  end

  private

  def fetch_vimeo_thumbnail(video_id)
    return nil if video_id.blank?

    cache_key = "vimeo_thumb_#{video_id}"
    Rails.cache.fetch(cache_key, expires_in: 24.hours) do
      begin
        uri = URI("https://vimeo.com/api/oembed.json?url=https://vimeo.com/#{video_id}")
        response = Net::HTTP.get_response(uri)
        return nil unless response.is_a?(Net::HTTPSuccess)

        data = JSON.parse(response.body)
        data["thumbnail_url"]
      rescue StandardError => e
        Rails.logger.error "Vimeo thumbnail error: #{e.message}"
        nil
      end
    end
  end
end
