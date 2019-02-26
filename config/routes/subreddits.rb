# frozen_string_literal: true

resources :subreddits, only: %i[index show] do
  member do
    get :game_threads
  end
end
