# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api, defaults: { format: 'json' } do
    namespace :accounts do
      get :authenticate
    end

    resources :game_threads, only: %i[index show create update destroy]

    controller :sessions do
      post   :login,  action: :create
      delete :logout, action: :destroy
    end

    resources :subreddits, only: %i[index show update] do
      get :game_threads, on: :member
      get :templates, on: :member
    end

    resources :templates, only: %i[show update]
  end

  get '*', to: 'app#app'

  root to: 'app#app', as: :app
end
