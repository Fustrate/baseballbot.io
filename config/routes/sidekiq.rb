# frozen_string_literal: true

require 'sidekiq/web'

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == Rails.application.credentials.dig(:sidekiq, :username) &&
    password == Rails.application.credentials.dig(:sidekiq, :password)
end

mount Sidekiq::Web => '/sidekiq'
