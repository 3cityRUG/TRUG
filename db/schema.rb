# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_08_094920) do
  create_table "attendances", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "github_username"
    t.integer "meetup_id"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "meetups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.text "description"
    t.string "event_type", default: "formal"
    t.string "location"
    t.integer "number"
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_meetups_on_event_type"
    t.index ["number"], name: "index_meetups_on_number", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "talks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "meetup_id", null: false
    t.string "slides_url"
    t.string "source_code_url"
    t.string "speaker_homepage"
    t.string "speaker_name", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "video_id"
    t.string "video_provider"
    t.string "video_thumb"
    t.index ["meetup_id"], name: "index_talks_on_meetup_id"
    t.index ["speaker_name"], name: "index_talks_on_speaker_name"
    t.index ["title"], name: "index_talks_on_title"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "github_id"
    t.string "github_username"
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["github_id"], name: "index_users_on_github_id", unique: true
  end

  add_foreign_key "sessions", "users"
  add_foreign_key "talks", "meetups"
end
