# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#home'

  Rails.root.glob('config/routes/*.rb').each { instance_eval File.read(it) }
end
