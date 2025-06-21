# frozen_string_literal: true

resources :game_threads

get '/gamechats', to: redirect('/game_threads')
