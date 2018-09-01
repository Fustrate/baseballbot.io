# frozen_string_literal: true

json.collection!(
  @game_threads,
  partial: 'game_threads/game_thread',
  as: :game_thread
)
