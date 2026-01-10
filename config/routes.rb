# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api, defaults: { format: 'json' } do
    resources :game_threads, only: %i[index show create update destroy]

    resources :subreddits, only: %i[index show update] do
      get :game_threads, on: :member
      get :templates, on: :member
    end

    resources :templates, only: %i[show update]

    resource :session, only: %i[show]
  end

  namespace :accounts do
    get :authenticate
  end

  controller :sessions do
    get    :sign_in
    delete :sign_out
    get    :authorized
  end

  get '*', to: 'app#app'

  root to: 'app#app', as: :app
end
