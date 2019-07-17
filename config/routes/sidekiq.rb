# frozen_string_literal: true

require 'sidekiq/web'

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == Rails.application.credentials.dig(:slack, :username) &&
    password == Rails.application.credentials.dig(:slack, :password)
end

mount Sidekiq::Web => '/sidekiq'
