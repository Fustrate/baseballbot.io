# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.6.6'
gem 'rails', '~> 6.0.3'

gem 'pg'

gem 'haml-rails'
gem 'jbuilder', '~> 2.10'
gem 'webpacker', '~> 5.0'

# Used to generate routes & i18n for the frontend
gem 'i18n-js'
gem 'js-routes', require: false

# Faster json generation
gem 'oj'

# A few custom services and initializers
gem 'fustrate-rails', github: 'Fustrate/fustrate-rails'

# Use Puma as the app server
gem 'puma'

# Reddit interaction
gem 'mlb_stats_api', github: 'Fustrate/mlb_stats_api'
gem 'redd' # , git: 'https://github.com/avinashbot/redd.git'

# App Monitoring
gem 'honeybadger', '~> 4.0'
gem 'skylight'

# Use ActiveStorage validations & variants
gem 'active_storage_validations'
gem 'image_processing'
# gem 'ratonvirus'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'guard-bundler', require: false
  gem 'guard-rails'
  gem 'guard-rspec', require: false
  gem 'ruby_gntp'
  gem 'web-console', '~> 4.0'

  # Deploy with Capistrano
  gem 'capistrano', '~> 3.11', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-rbenv', '~> 2.1', require: false
  gem 'capistrano3-puma', github: 'seuros/capistrano-puma'

  # Linters
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false

  gem 'pry'
  gem 'pry-rails'
end

group :development, :test do
  gem 'rspec-rails', '~> 4.0'

  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  gem 'rspec-collection_matchers'

  gem 'capybara'
  gem 'mock_redis'

  gem 'database_cleaner', '~> 1.5'
  gem 'factory_bot_rails'
  gem 'launchy'
  gem 'rails-controller-testing', require: false
end

# "is_active" links in views, and pagination
gem 'active_link_to'
gem 'will_paginate', '~> 3.1'

# Authentication and permissions
gem 'authority'
gem 'sorcery'

# Cron jobs
gem 'whenever'

gem 'chronic'
gem 'redis'

# Communication with the Discord bot
gem 'em-hiredis'
gem 'eventmachine'

gem 'sidekiq', '~> 6.0'
gem 'sidekiq-history'
