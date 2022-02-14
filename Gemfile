# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.1.0'
gem 'rails', '~> 7.0.2'

gem 'pg', '~> 1.2'

# HTML & JSON views
gem 'haml-rails', '~> 2.0'
gem 'jbuilder', '~> 2.11'

# Front end compilation
gem 'cssbundling-rails', '~> 1.0'
gem 'jsbundling-rails', '~> 1.0'
gem 'propshaft', '~> 0.6'

# Used to generate routes for the frontend
gem 'js-routes', '~> 2.1', require: false

# Faster json generation
gem 'oj', '~> 3.13'

# A few custom services and initializers
gem 'fustrate-rails', '~> 0.8', github: 'Fustrate/fustrate-rails'

# Use Puma as the app server
gem 'puma', '~> 5.5'

# Reddit interaction
gem 'mlb_stats_api', '~> 0.2', github: 'Fustrate/mlb_stats_api'
gem 'redd', '~> 0.8'
# gem 'redd', '~> 0.8', git: 'https://github.com/avinashbot/redd.git'

# App Monitoring
gem 'honeybadger', '~> 4.9'
gem 'listen', '~> 3.7'
gem 'skylight', '~> 5.1'

group :development do
  gem 'bullet', '~> 7.0'

  # Access an IRB console on exception pages or by using `= console` in views
  gem 'web-console', '~> 4.2'

  # Deploy with Capistrano
  gem 'capistrano', '~> 3.16', require: false
  gem 'capistrano-bundler', '~> 2.0', require: false
  gem 'capistrano-rails', '~> 1.6', require: false
  gem 'capistrano-rbenv', '~> 2.2', require: false

  # Linters
  gem 'rubocop', '~> 1.23', require: false
  gem 'rubocop-performance', '~> 1.12', require: false
  gem 'rubocop-rails', '~> 2.12', require: false
  gem 'rubocop-rspec', '~> 2.6', require: false
end

group :development, :test do
  # Start debugger with binding.b [https://github.com/ruby/debug]
  gem 'debug', '~> 1.3'

  gem 'rspec-rails', '~> 5.0'
end

group :test do
  gem 'rspec-collection_matchers', '~> 1.2'

  gem 'capybara', '~> 3.36'
  gem 'mock_redis', '~> 0.29'

  gem 'database_cleaner', '~> 2.0'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'launchy', '~> 2.5'
  gem 'rails-controller-testing', '~> 1.0', require: false

  # Easy installation and use of web drivers to run system tests with browsers
  gem 'selenium-webdriver', '~> 4.1'
  gem 'webdrivers', '~> 5.0'
end

# "is_active" links in views
gem 'active_link_to', '~> 1.0'

# Pagination
gem 'will_paginate', '~> 3.3'

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
