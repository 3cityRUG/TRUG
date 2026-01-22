class CreateTalks < ActiveRecord::Migration[8.1]
  def change
    create_table :talks do |t|
      t.references :meetup, null: false, foreign_key: true
      t.string :title, null: false
      t.string :speaker_name, null: false
      t.string :speaker_homepage
      t.string :slides_url
      t.string :source_code_url
      t.string :video_id
      t.string :video_provider
      t.string :video_thumb
      t.timestamps
    end

    add_index :talks, :title
    add_index :talks, :speaker_name
  end
end
