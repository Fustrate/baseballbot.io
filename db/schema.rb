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

ActiveRecord::Schema.define(version: 2018_10_25_011756) do

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

  create_table "game_threads", id: :serial, force: :cascade do |t|
    t.datetime "post_at"
    t.datetime "starts_at"
    t.string "status"
    t.string "title"
    t.string "post_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }
    t.integer "subreddit_id", null: false
    t.integer "game_pk"
    t.string "type"
    t.index "game_pk, subreddit_id, date_trunc('day'::text, starts_at)", name: "index_game_threads_on_game_pk_subreddit_date_unique", unique: true, where: "(type IS NULL)"
    t.index "game_pk, subreddit_id, date_trunc('day'::text, starts_at), type", name: "index_game_threads_on_game_pk_subreddit_date_type_unique", unique: true
  end

  create_table "scheduled_posts", id: :serial, force: :cascade do |t|
    t.datetime "next_post_at"
    t.string "title"
    t.text "body"
    t.integer "subreddit_id", null: false
    t.json "options"
  end

  create_table "subreddit_users", id: false, force: :cascade do |t|
    t.bigint "subreddit_id", null: false
    t.bigint "user_id", null: false
    t.index ["subreddit_id"], name: "index_subreddit_users_on_subreddit_id"
    t.index ["user_id"], name: "index_subreddit_users_on_user_id"
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

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.string "crypted_password"
    t.string "salt"
    t.datetime "lock_expires_at"
    t.integer "failed_logins_count", default: 0
    t.string "unlock_token"
    t.datetime "last_activity_at"
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.string "last_login_from_ip_address"
    t.datetime "remember_me_token_expires_at"
    t.string "remember_me_token"
    t.datetime "reset_password_email_sent_at"
    t.datetime "reset_password_token_expires_at"
    t.integer "access_count_to_reset_password_page", default: 0
    t.string "reset_password_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["last_logout_at", "last_activity_at"], name: "index_users_on_last_logout_at_and_last_activity_at"
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
    t.index ["unlock_token"], name: "index_users_on_unlock_token"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
