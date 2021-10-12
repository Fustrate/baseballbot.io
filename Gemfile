# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.0.2'
gem 'rails', '~> 6.1.4'

gem 'pg', '~> 1.2'

gem 'haml-rails', '~> 2.0'
gem 'jbuilder', '~> 2.10'
gem 'webpacker', '>= 6.0.0.rc.5'

# Used to generate routes for the frontend
gem 'js-routes', '~> 2.0', require: false

# Faster json generation
gem 'oj', '~> 3.11'

# A few custom services and initializers
gem 'fustrate-rails', '~> 0.8', github: 'Fustrate/fustrate-rails'

# Use Puma as the app server
gem 'puma', '~> 5.5'

# Reddit interaction
gem 'mlb_stats_api', '~> 0.2', github: 'Fustrate/mlb_stats_api'
gem 'redd', '~> 0.8'
# gem 'redd', '~> 0.8', git: 'https://github.com/avinashbot/redd.git'

# App Monitoring
gem 'honeybadger', '~> 4.0'
gem 'listen', '~> 3.3'
gem 'skylight', '~> 5.0'

# Use ActiveStorage validations & variants
gem 'active_storage_validations', '~> 0.9'
gem 'image_processing', '~> 1.12'
# gem 'ratonvirus'

group :development do
  gem 'bullet', '~> 6.1'

  # Access an IRB console on exception pages or by using `= console` in views
  gem 'web-console', '~> 4.1'

  # Deploy with Capistrano
  gem 'capistrano', '~> 3.11', require: false
  gem 'capistrano-bundler', '~> 2.0', require: false
  gem 'capistrano-rails', '~> 1.6', require: false
  gem 'capistrano-rbenv', '~> 2.2', require: false

  # Linters
  gem 'rubocop', '~> 1.14', require: false
  gem 'rubocop-performance', '~> 1.11', require: false
  gem 'rubocop-rails', '~> 2.10', require: false
  gem 'rubocop-rspec', '~> 2.3', require: false

  gem 'pry-rails', '~> 0.3'
end

group :development, :test do
  gem 'rspec-rails', '~> 5.0'
end

group :test do
  gem 'rspec-collection_matchers', '~> 1.2'

  gem 'capybara', '~> 3.35'
  gem 'mock_redis', '~> 0.28'

  gem 'database_cleaner', '~> 2.0'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'launchy', '~> 2.5'
  gem 'rails-controller-testing', '~> 1.0', require: false

  # Easy installation and use of web drivers to run system tests with browsers
  gem 'selenium-webdriver', '>= 4.0.0.beta3'
  gem 'webdrivers', '~> 4.6'
end

# "is_active" links in views
gem 'active_link_to', '~> 1.0'

# Pagination
gem 'will_paginate', '~> 3.1'

# Authentication
gem 'sorcery', '~> 0.16'

# Permissions
gem 'authority', '~> 3.3'

gem 'chronic', '~> 0.10'
gem 'redis', '~> 4.4'

# Communication with the Discord bot
gem 'em-hiredis', '~> 0.3'
gem 'eventmachine', '~> 1.2'

gem 'sidekiq', '< 7'
gem 'sidekiq-history', '~> 0.0.12'
