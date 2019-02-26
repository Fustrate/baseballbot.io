# frozen_string_literal: true

json.call(
  game_thread, :id, :post_at, :starts_at, :status, :title, :post_id, :game_pk,
  :created_at, :updated_at
)

unless local_assigns[:subreddit] == false
  json.subreddit game_thread.subreddit, :id, :name, :team_id
end
