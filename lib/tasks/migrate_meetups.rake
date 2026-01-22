namespace :meetups do
  desc "Migrate meetup data from YAML file"
  task migrate_from_yaml: :environment do
    yaml_path = Rails.root.join("..", "data", "meetups.yml")

    unless File.exist?(yaml_path)
      puts "ERROR: Could not find meetups.yml at #{yaml_path}"
      exit 1
    end

    data = YAML.load_file(yaml_path)
    events = data["events"]

    puts "Found #{events.count} meetups to import..."

    meetups_created = 0
    talks_created = 0

    ActiveRecord::Base.transaction do
      events.each do |event|
        meetup = Meetup.find_or_initialize_by(number: event["number"])
        meetup.date = event["date"]

        if meetup.new_record?
          meetup.save!
          meetups_created += 1
        end

        (event["talks"] || []).each do |talk_data|
          next if talk_data["title"].blank?

          video_thumb = talk_data["video_thumb"]

          if talk_data["video_provider"] == "vimeo" && video_thumb.blank?
            video_thumb = fetch_vimeo_thumb(talk_data["video_id"])
          end

          talk = Talk.new(
            meetup: meetup,
            title: talk_data["title"],
            speaker_name: talk_data["full_name"].presence || "Nieznany prelegent",
            speaker_homepage: talk_data["home_page"],
            slides_url: talk_data["slides"],
            source_code_url: talk_data["source_code"],
            video_id: talk_data["video_id"],
            video_provider: talk_data["video_provider"],
            video_thumb: video_thumb
          )
          talk.save!
          talks_created += 1
        end
      end
    end

    puts "Successfully imported:"
    puts "  - #{meetups_created} new meetups"
    puts "  - #{talks_created} new talks"
    puts ""
    puts "Total meetups in database: #{Meetup.count}"
    puts "Total talks in database: #{Talk.count}"
  end

  desc "Fetch missing Vimeo video thumbnails"
  task fetch_vimeo_thumbs: :environment do
    talks = Talk.where(video_provider: "vimeo").where(video_thumb: [ nil, "" ])
    puts "Found #{talks.count} Vimeo talks without thumbnails..."

    talks.find_each do |talk|
      next if talk.video_id.blank?

      thumb = fetch_vimeo_thumb(talk.video_id)
      if thumb
        talk.update!(video_thumb: thumb)
        puts "  Updated talk ##{talk.id}: #{talk.title[0..50]}..."
        sleep 0.5
      end
    end

    puts "Done! Remaining talks without thumbs: #{Talk.where(video_provider: 'vimeo').where(video_thumb: [ nil, '' ]).count}"
  end
end

def fetch_vimeo_thumb(video_id)
  return nil if video_id.blank?

  begin
    url = "https://vimeo.com/api/v2/video/#{video_id}.json"
    response = Net::HTTP.get(URI(url))
    data = JSON.parse(response)

    if data.is_a?(Array) && data.first
      return data.first["thumbnail_large"] ||
             data.first["thumbnail_medium"] ||
             data.first["thumbnail_small"]
    end
  rescue => e
    puts "  Error fetching thumb for #{video_id}: #{e.message}"
  end

  nil
end
