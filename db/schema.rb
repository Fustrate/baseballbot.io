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

ActiveRecord::Schema.define(version: 20170404035219) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", id: :integer, default: -> { "nextval('users_id_seq'::regclass)" }, force: :cascade do |t|
    t.string   "name"
    t.string   "access_token"
    t.string   "refresh_token"
    t.string   "scope",         default: [], array: true
    t.datetime "expires_at"
  end

  create_table "events", force: :cascade do |t|
    t.string   "eventable_type"
    t.integer  "eventable_id"
    t.string   "type"
    t.string   "note"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["eventable_type", "eventable_id"], name: "index_events_on_eventable_type_and_eventable_id", using: :btree
  end

  create_table "gamechats", force: :cascade do |t|
    t.string   "gid"
    t.datetime "post_at"
    t.datetime "starts_at"
    t.string   "status"
    t.string   "title"
    t.string   "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "subreddit_id", null: false
    t.index ["gid", "subreddit_id"], name: "index_gamechats_on_gid_and_subreddit_id", unique: true, using: :btree
  end

  create_table "scheduled_posts", force: :cascade do |t|
    t.datetime "next_post_at"
    t.string   "title"
    t.text     "body"
    t.integer  "subreddit_id", null: false
    t.json     "options"
  end

  create_table "subreddits", force: :cascade do |t|
    t.string  "name"
    t.string  "team_code"
    t.integer "account_id"
    t.json    "options"
  end

  create_table "templates", force: :cascade do |t|
    t.text     "body"
    t.string   "type"
    t.integer  "subreddit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

end
