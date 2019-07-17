# frozen_string_literal: true

module BaseballbotIo
  class Application < Rails::Application
    attr_accessor :redis
  end
end

Rails.application.redis = Redis.new(host: 'localhost', port: 6379)

# 0: Rails
# 1: ActionCable
# 2: Sidekiq
