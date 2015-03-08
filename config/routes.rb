Rails.application.routes.draw do
  root to: 'home#home'

  namespace :reddit do
    get :authenticate

    root action: :index
  end
end
