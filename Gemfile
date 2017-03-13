# frozen_string_literal: true
source 'https://rubygems.org'

ruby '2.4.0'
gem 'rails', '5.0.2'

gem 'pg'

gem 'coffee-rails'
gem 'foundation-rails', '~> 5.0'
gem 'haml-rails'
gem 'jquery-rails'
gem 'modernizr-rails'

gem 'execjs'

gem 'uglifier', '>= 2.6.0'

# Turbolinks makes following links in your web application faster.
# Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Use Unicorn as the app server
gem 'unicorn'

# Reddit interaction
gem 'mlb_gameday', '~> 0.1'
gem 'redd', git: 'https://github.com/avinashbot/redd.git'

group :production do
  gem 'honeybadger'
  gem 'skylight'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'guard-bundler', require: false
  gem 'guard-rails'
  gem 'guard-rspec', require: false
  gem 'rubocop'
  gem 'ruby_gntp'
  gem 'web-console', '~> 3.0'

  # Deploy with Capistrano
  gem 'capistrano', '~> 3.6', require: false
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv', '~> 2.0'
end

group :test do
  gem 'capybara'
  gem 'mock_redis'
  gem 'simplecov', require: false
end

group :development, :test do
  gem 'database_cleaner', '~> 1.5'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'rspec', '~> 3.0'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'

  gem 'byebug'

  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'
end

# "is_active" links in views, and pagination
gem 'active_link_to'
gem 'will_paginate', '~> 3.0'

# Authentication and permissions
gem 'authority'
gem 'sorcery'

# Cron jobs
gem 'whenever', require: false

# Rails 4 stuff!
gem 'activerecord-session_store'

gem 'chronic'
gem 'redis'
