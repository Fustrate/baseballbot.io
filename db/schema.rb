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

ActiveRecord::Schema[8.1].define(version: 2026_01_25_010704) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

  create_table "bot_actions", force: :cascade do |t|
    t.string "action", null: false
    t.jsonb "data"
    t.datetime "date", precision: nil, default: -> { "now()" }
    t.string "note"
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.index ["subject_type", "subject_id"], name: "index_bot_actions_on_subject_type_and_subject_id"
  end

  create_table "bots", id: :serial, force: :cascade do |t|
    t.string "access_token"
    t.datetime "expires_at", precision: nil
    t.citext "name"
    t.string "refresh_token"
    t.string "scope", default: [], array: true
  end

  create_table "edits", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "editable_id", null: false
    t.string "editable_type", null: false
    t.text "note"
    t.jsonb "pretty_changes", default: {}, null: false
    t.jsonb "raw_changes", default: {}, null: false
    t.string "reason"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "user_type", null: false
    t.index ["editable_type", "editable_id"], name: "index_edits_on_editable"
    t.index ["user_type", "user_id"], name: "index_edits_on_user"
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "eventable_id"
    t.string "eventable_type"
    t.string "note"
    t.string "type"
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id", null: false
    t.string "user_type", null: false
    t.index ["eventable_type", "eventable_id"], name: "index_events_on_eventable_type_and_eventable_id"
    t.index ["user_type", "user_id"], name: "index_events_on_user_type_and_user_id"
  end

  create_table "game_threads", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.integer "game_pk"
    t.jsonb "options", default: {}, null: false
    t.datetime "post_at", precision: nil
    t.string "post_game_post_id"
    t.string "post_id"
    t.string "pre_game_post_id"
    t.datetime "starts_at", precision: nil
    t.string "status"
    t.integer "subreddit_id", null: false
    t.string "title"
    t.string "type"
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
    t.index "game_pk, subreddit_id, date_trunc('day'::text, starts_at)", name: "index_game_threads_on_game_pk_subreddit_date_unique", unique: true, where: "(type IS NULL)"
    t.index "game_pk, subreddit_id, date_trunc('day'::text, starts_at), type", name: "index_game_threads_on_game_pk_subreddit_date_type_unique", unique: true
  end

  create_table "modmails", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "reddit_id"
    t.boolean "status"
    t.string "subject"
    t.bigint "subreddit_id", null: false
    t.bigint "thread_id"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["subreddit_id"], name: "index_modmails_on_subreddit_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.string "code_challenge"
    t.string "code_challenge_method"
    t.datetime "created_at", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.bigint "resource_owner_id", null: false
    t.string "resource_owner_type", null: false
    t.datetime "revoked_at"
    t.string "scopes", default: "", null: false
    t.string "token", null: false
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id", "resource_owner_type"], name: "polymorphic_owner_oauth_access_grants"
    t.index ["resource_owner_type", "resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.datetime "created_at", null: false
    t.integer "expires_in"
    t.string "previous_refresh_token", default: "", null: false
    t.string "refresh_token"
    t.bigint "resource_owner_id"
    t.string "resource_owner_type"
    t.datetime "revoked_at"
    t.string "scopes"
    t.string "token", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id", "resource_owner_type"], name: "polymorphic_owner_oauth_access_tokens"
    t.index ["resource_owner_type", "resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.string "secret", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "scheduled_posts", id: :serial, force: :cascade do |t|
    t.text "body"
    t.datetime "next_post_at", precision: nil
    t.jsonb "options"
    t.integer "subreddit_id", null: false
    t.string "title"
  end

  create_table "subreddits", id: :serial, force: :cascade do |t|
    t.integer "bot_id"
    t.string "moderators", default: [], array: true
    t.citext "name"
    t.jsonb "options"
    t.string "slack_id"
    t.string "team_code"
    t.integer "team_id"
  end

  create_table "subreddits_users", id: false, force: :cascade do |t|
    t.bigint "subreddit_id", null: false
    t.bigint "user_id", null: false
    t.index ["subreddit_id"], name: "index_subreddits_users_on_subreddit_id"
    t.index ["user_id"], name: "index_subreddits_users_on_user_id"
  end

  create_table "system_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.datetime "updated_at", null: false
    t.string "username", null: false
  end

  create_table "templates", id: :serial, force: :cascade do |t|
    t.json "blocks"
    t.text "body"
    t.datetime "created_at", precision: nil
    t.integer "subreddit_id"
    t.string "type"
    t.datetime "updated_at", precision: nil
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "last_activity_at", precision: nil
    t.datetime "last_login_at", precision: nil
    t.string "last_login_from_ip_address"
    t.datetime "last_logout_at", precision: nil
    t.string "remember_me_token"
    t.datetime "remember_me_token_expires_at", precision: nil
    t.string "type", default: "user", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.citext "username", null: false
    t.index ["last_logout_at", "last_activity_at"], name: "index_users_on_last_logout_at_and_last_activity_at"
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "game_threads", "subreddits"
  add_foreign_key "modmails", "subreddits"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "scheduled_posts", "subreddits"
  add_foreign_key "subreddits", "bots"
  add_foreign_key "subreddits_users", "subreddits"
  add_foreign_key "subreddits_users", "users"
  add_foreign_key "templates", "subreddits"
end
