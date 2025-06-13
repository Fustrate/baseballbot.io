# frozen_string_literal: true

# Use a second redis instance so that we don't run into potential future
# memory issues, causing jobs to be deleted in favor of the cache

Sidekiq.configure_server do |config|
  config.queues = %w[default]

  config[:timeout] = 15
  config[:concurrency] = 5

  config.redis = { url: 'redis://localhost:6379/2' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/2' }
end
