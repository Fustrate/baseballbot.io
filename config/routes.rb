# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#home'

  Dir[Rails.root.join('config/routes/*.rb')].each { instance_eval File.read(_1) }
end
