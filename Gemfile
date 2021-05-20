# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.0.1'
gem 'rails', '~> 6.1.3'

gem 'pg', '~> 1.2'

gem 'haml-rails'
gem 'jbuilder', '~> 2.10'
gem 'webpacker', '6.0.0.beta.7'

# Used to generate routes & i18n for the frontend
gem 'i18n-js', '~> 3.8'
gem 'js-routes', '~> 2.0', require: false

# Faster json generation
gem 'oj', '~> 3.11'

# A few custom services and initializers
gem 'fustrate-rails', github: 'Fustrate/fustrate-rails'

# Use Puma as the app server
gem 'puma', '~> 5.3'

# Reddit interaction
gem 'mlb_stats_api', github: 'Fustrate/mlb_stats_api'
gem 'redd' # , git: 'https://github.com/avinashbot/redd.git'

# App Monitoring
gem 'honeybadger', '~> 4.0'
gem 'skylight', '~> 5.0'

# Use ActiveStorage validations & variants
gem 'active_storage_validations', '~> 0.9'
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

  # Linters
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false

  gem 'pry-rails', '~> 0.3'
end

group :development, :test do
  gem 'rspec-rails', '~> 5.0'

  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  gem 'rspec-collection_matchers'

  gem 'capybara'
  gem 'mock_redis'

  gem 'database_cleaner', '~> 2.0'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'launchy'
  gem 'rails-controller-testing', require: false
end

# "is_active" links in views, and pagination
gem 'active_link_to', '~> 1.0'
gem 'will_paginate', '~> 3.1'

# Authentication and permissions
gem 'authority'
gem 'sorcery'

gem 'chronic', '~> 0.10'
gem 'redis'

# Communication with the Discord bot
gem 'em-hiredis'
gem 'eventmachine'

gem 'sidekiq', '~> 6.0'
gem 'sidekiq-history'
