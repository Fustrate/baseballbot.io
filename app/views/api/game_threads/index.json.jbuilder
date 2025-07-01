# frozen_string_literal: true

json.data(@game_threads) do |game_thread|
  json.call(
    game_thread, :id, :post_at, :starts_at, :status, :title, :post_id, :game_pk, :pre_game_post_id, :post_game_post_id,
    :created_at, :updated_at
  )

  json.subreddit game_thread.subreddit, :id, :name, :team_id, :options
end

json.pagination! @pagination
