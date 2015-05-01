Rails.application.routes.draw do
  root to: 'home#home'

  namespace :accounts do
    get :authenticate
  end

  resources :subreddits, only: %i(index)
end
