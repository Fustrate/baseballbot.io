# frozen_string_literal: true

Rails.application.routes.draw do
  constraints subdomain: 'app' do
    get '*', to: 'app#app'

    root to: 'app#app', as: :app
  end

  constraints subdomain: '' do
    Rails.root.glob('config/routes/*.rb').each { instance_eval File.read(it) }

    root to: 'home#home'
  end
end
