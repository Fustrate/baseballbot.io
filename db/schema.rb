# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_02_04_004826) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "access_token"
    t.string "refresh_token"
    t.string "scope", default: [], array: true
    t.datetime "expires_at"
  end

  create_table "bot_actions", force: :cascade do |t|
    t.string "subject_type", null: false
    t.bigint "subject_id", null: false
    t.string "action", null: false
    t.string "note"
    t.json "data"
    t.datetime "date", default: -> { "now()" }
    t.index ["subject_type", "subject_id"], name: "index_bot_actions_on_subject_type_and_subject_id"
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
    t.datetime "created_at", default: -> { "now()" }
    t.datetime "updated_at", default: -> { "now()" }
    t.integer "subreddit_id", null: false
    t.integer "game_pk"
    t.string "type"
    t.string "pre_game_post_id"
    t.string "post_game_post_id"
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

  add_foreign_key "templates", "subreddits"
end
