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

ActiveRecord::Schema.define(version: 20180429223112) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "access_token"
    t.string "refresh_token"
    t.string "scope", default: [], array: true
    t.datetime "expires_at"
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.string "eventable_type"
    t.integer "eventable_id"
    t.string "type"
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["eventable_type", "eventable_id"], name: "index_events_on_eventable_type_and_eventable_id"
  end

  create_table "gamechats", id: :serial, force: :cascade do |t|
    t.datetime "post_at"
    t.datetime "starts_at"
    t.string "status"
    t.string "title"
    t.string "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "subreddit_id", null: false
    t.integer "game_pk"
    t.index "game_pk, subreddit_id, date_trunc('day'::text, starts_at)", name: "index_gamechats_on_game_pk_subreddit_date_unique", unique: true
  end

  create_table "scheduled_posts", id: :serial, force: :cascade do |t|
    t.datetime "next_post_at"
    t.string "title"
    t.text "body"
    t.integer "subreddit_id", null: false
    t.json "options"
  end

  create_table "subreddits", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "team_code"
    t.integer "account_id"
    t.json "options"
    t.integer "team_id"
  end

  create_table "templates", id: :serial, force: :cascade do |t|
    t.text "body"
    t.string "type"
    t.integer "subreddit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "title"
  end

end
