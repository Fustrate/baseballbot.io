# frozen_string_literal: true

json.paginated_collection!(
  @game_threads,
  partial: 'game_threads/game_thread',
  as: :game_thread
)
