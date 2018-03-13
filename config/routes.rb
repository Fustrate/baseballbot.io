# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#home'

  namespace :accounts do
    get :authenticate
  end

  resources :gamechats
  resources :subreddits, only: %i[index show]
  resources :templates, only: %i[show]

  get :gameday, to: 'home#gameday'
end
