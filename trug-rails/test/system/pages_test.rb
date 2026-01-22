require "application_system_test_case"

class PagesTest < ApplicationSystemTestCase
  driven_by :selenium, using: :headless_chrome

  test "homepage shows TRUG title" do
    visit root_url
    assert_text "Trójmiejska Grupa"
    assert_text "Użytkowników Ruby"
  end

  test "archive page lists all meetups" do
    visit archive_url
    assert_selector ".archive-meetup"
    assert Meetup.count > 0, "Should have meetups in database"
  end

  test "archive page shows meetup details" do
    visit archive_url
    meetup = Meetup.ordered.first
    assert page.has_content?("##{meetup.number}")
    assert page.has_content?(I18n.l(meetup.date, format: :long))
  end

  test "archive page shows talks for each meetup" do
    visit archive_url
    talk = Talk.joins(:meetup).merge(Meetup.ordered).first
    assert page.has_content?(talk.title) if talk.present?
  end

  test "archive page shows YouTube video thumbnails" do
    youtube_talk = Talk.find_by(video_provider: "youtube")
    skip "No YouTube talks found in database" unless youtube_talk.present?

    visit archive_url
    assert_selector ".video-container[data-video-provider=\"youtube\"][data-video-id=\"#{youtube_talk.video_id}\"]"
    assert_selector ".video-placeholder img[loading=\"lazy\"]"
  end

  test "archive page shows Vimeo video thumbnails" do
    vimeo_talk = Talk.find_by(video_provider: "vimeo")
    skip "No Vimeo talks found in database" unless vimeo_talk.present?

    visit archive_url
    assert_selector ".video-container[data-video-provider=\"vimeo\"][data-video-id=\"#{vimeo_talk.video_id}\"]"
    assert_selector ".video-placeholder img[loading=\"lazy\"]"
  end

  test "YouTube video thumbnail uses correct URL format" do
    visit archive_url
    youtube_container = find(".video-container[data-video-provider=\"youtube\"]", match: :first, wait: 5)
    img = youtube_container.find(".video-placeholder img")
    src = img[:src]
    assert src.include?("img.youtube.com"), "YouTube thumbnail should use YouTube CDN"
  end

  test "Vimeo video thumbnail uses proxy endpoint" do
    vimeo_talk = Talk.find_by(video_provider: "vimeo")
    skip "No Vimeo talks found in database" unless vimeo_talk.present?

    visit archive_url
    vimeo_container = find(".video-container[data-video-provider=\"vimeo\"][data-video-id=\"#{vimeo_talk.video_id}\"]", wait: 5)
    img = vimeo_container.find(".video-placeholder img")
    src = img[:src]
    assert src.include?("/video-thumbnails/vimeo/"), "Vimeo thumbnail should use proxy endpoint"
  end

  test "video placeholder has play button icon" do
    talk_with_video = Talk.where.not(video_id: nil).where.not(video_id: "").first
    skip "No talks with videos found" unless talk_with_video.present?

    visit archive_url
    assert_selector ".video-placeholder .play-icon", visible: true
  end

  test "clicking video placeholder loads iframe" do
    talk_with_video = Talk.where.not(video_id: nil).where.not(video_id: "").first
    skip "No talks with videos found" unless talk_with_video.present?

    visit archive_url
    video_container = find(".video-container[data-video-id=\"#{talk_with_video.video_id}\"]", wait: 5)
    video_container.find(".video-placeholder").click
    assert_selector ".video-container iframe.video-iframe", wait: 2
  end

  test "YouTube iframe has correct src" do
    youtube_talk = Talk.find_by(video_provider: "youtube")
    skip "No YouTube talks found in database" unless youtube_talk.present?

    visit archive_url
    video_container = find(".video-container[data-video-id=\"#{youtube_talk.video_id}\"]", wait: 5)
    video_container.find(".video-placeholder").click
    iframe = find(".video-container iframe.video-iframe", wait: 2)
    src = iframe[:src]
    assert src.include?("youtube.com/embed/"), "Iframe src should be YouTube embed URL"
    assert src.include?(youtube_talk.video_id), "Iframe should contain video ID"
    assert src.include?("autoplay=1"), "Video should autoplay"
  end

  test "Vimeo iframe has correct src" do
    vimeo_talk = Talk.find_by(video_provider: "vimeo")
    skip "No Vimeo talks found in database" unless vimeo_talk.present?

    visit archive_url
    video_container = find(".video-container[data-video-id=\"#{vimeo_talk.video_id}\"]", wait: 5)
    video_container.find(".video-placeholder").click
    iframe = find(".video-container iframe.video-iframe", wait: 2)
    src = iframe[:src]
    assert src.include?("player.vimeo.com/video/"), "Iframe src should be Vimeo player URL"
    assert src.include?(vimeo_talk.video_id), "Iframe should contain video ID"
    assert src.include?("autoplay=true"), "Video should autoplay"
  end

  test "talks show slides link when present" do
    talk_with_slides = Talk.where.not(slides_url: nil).where.not(slides_url: "").first
    skip "No talks with slides found" unless talk_with_slides.present?

    visit archive_url
    talk_section = find(".archive-talk", text: talk_with_slides.title, wait: 5)
    assert talk_section.has_link?("Slajdy prezentacji")
  end

  test "talks show source code link when present" do
    talk_with_source = Talk.where.not(source_code_url: nil).where.not(source_code_url: "").first
    skip "No talks with source code found" unless talk_with_source.present?

    visit archive_url
    talk_section = find(".archive-talk", text: talk_with_source.title, wait: 5)
    assert talk_section.has_link?("Kod źródłowy")
  end

  test "navbar has archive link" do
    visit root_url
    assert_selector ".navbar .navbar-brand[href=\"/\"]"
    assert page.has_link?("Archiwum", href: "/archive")
  end

  test "footer has newsletter form" do
    visit root_url
    assert_selector ".footer form input[type=\"email\"]"
    assert_selector ".footer form button[type=\"submit\"]"
  end

  test "archive page is accessible from navbar" do
    visit root_url
    click_link "Archiwum"
    assert_current_path "/archive"
    assert_text "Archiwum spotkań"
  end

  test "multiple talks per meetup are displayed" do
    meetup_with_multiple_talks = Meetup.joins(:talks).group(:id).having("COUNT(talks.id) > 1").first
    skip "No meetups with multiple talks found" unless meetup_with_multiple_talks.present?

    visit archive_url
    meetup_section = find(".archive-meetup#meetup-#{meetup_with_multiple_talks.number}", wait: 5)
    talks_count = meetup_section.all(".archive-talk").count
    assert talks_count >= 2, "Meetup should have at least 2 talks displayed"
  end

  test "video thumbnails have lazy loading attribute" do
    visit archive_url
    assert all("img[loading=\"lazy\"]").count > 0
    video_images = all(".video-placeholder img")
    video_images.each do |img|
      assert_equal "lazy", img[:loading], "Video thumbnails should have lazy loading"
    end
  end
end
