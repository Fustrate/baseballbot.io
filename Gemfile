# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.6.1'
gem 'rails', '5.2.2'

gem 'pg'

gem 'coffee-rails', '~> 4.2'
gem 'execjs'
gem 'haml-rails'
gem 'jbuilder'
gem 'jquery-rails'
gem 'sassc-rails', '~> 2.1'
gem 'sprockets-rails'
gem 'uglifier', '~> 4.1'

gem 'webpacker', '4.0.0.rc.7'

# Faster json generation
gem 'oj'

gem 'fustrate-rails', github: 'Fustrate/fustrate-rails'

# Use Unicorn as the app server
gem 'unicorn'

# Reddit interaction
gem 'mlb_stats_api', github: 'Fustrate/mlb_stats_api' # '~> 0.1'
gem 'redd' # , git: 'https://github.com/avinashbot/redd.git'

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
  gem 'ruby_gntp'
  gem 'web-console', '~> 3.6'

  # Deploy with Capistrano
  gem 'capistrano', '~> 3.10', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-rbenv', '~> 2.1', require: false

  # Linters
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'capybara'
  gem 'mock_redis'
  gem 'simplecov', require: false
end

group :development, :test do
  # gem 'database_cleaner', '~> 1.6'
  # gem 'factory_bot_rails'
  # gem 'launchy'
  gem 'rspec', '~> 3.7'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'

  gem 'byebug'

  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'
end

# "is_active" links in views, and pagination
gem 'active_link_to'
gem 'will_paginate', '~> 3.1'

# Authentication and permissions
gem 'authority'
gem 'sorcery'

# Cron jobs
gem 'whenever', require: false

gem 'chronic'
gem 'redis'

# Communication with the Discord bot
gem 'em-hiredis'
gem 'eventmachine'
