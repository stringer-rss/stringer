# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2014_11_02_103617) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "feeds", force: :cascade do |t|
    t.string "name"
    t.text "url"
    t.datetime "last_fetched"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "status"
    t.integer "group_id"
    t.index ["url"], name: "index_feeds_on_url", unique: true
  end

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stories", force: :cascade do |t|
    t.text "title"
    t.text "permalink"
    t.text "body"
    t.integer "feed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published"
    t.boolean "is_read"
    t.boolean "keep_unread", default: false
    t.boolean "is_starred", default: false
    t.text "entry_id"
    t.index ["entry_id", "feed_id"], name: "index_stories_on_entry_id_and_feed_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "setup_complete"
    t.string "api_key"
  end

end
