# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#home'

  namespace :accounts do
    get :authenticate
  end

  resources :gamechats
  resources :subreddits, only: %i(index)
end
