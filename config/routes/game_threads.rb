# frozen_string_literal: true

resources :game_threads

# Temporary? Ha.
get :gamechats, to: 'game_threads#index'
