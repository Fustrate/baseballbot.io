# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#home'

  namespace :accounts do
    get :authenticate
  end

  resources :game_threads
  resources :subreddits, only: %i[index show]
  resources :templates, only: %i[show]

  get :gameday, to: 'home#gameday'

  namespace :discord do
    get 'reddit-callback'
    get 'debug'
  end

  # Temporary? Ha.
  get :gamechats, to: 'game_threads#index'
end
