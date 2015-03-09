source 'https://rubygems.org'

ruby '2.2.1'
gem 'rails', '4.2.0'

gem 'pg'

gem 'sass'
gem 'jquery-rails'
gem 'coffee-rails'
gem 'haml-rails'
gem 'bourbon'
gem 'modernizr-rails'

gem 'execjs'

gem 'uglifier', '>= 2.6.0'

# Turbolinks makes following links in your web application faster.
# Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Use Unicorn as the app server
gem 'unicorn'

# Reddit interaction
gem 'redd', github: 'avidw/redd'

group :development do
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'guard-rspec', require: false
  gem 'guard-bundler', require: false
  gem 'guard-rails'
  gem 'ruby_gntp'
  gem 'rubocop'
  gem 'letter_opener'
  gem 'bullet'
  gem 'web-console', '~> 2.0'

  # Deploy with Capistrano
  gem 'capistrano', '~> 3.3', require: false
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-rbenv', '~> 2.0'
end

group :test do
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'timecop'
  gem 'mock_redis'
  gem 'simplecov', require: false
end

group :development, :test do
  gem 'rspec', '~> 3.0'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'database_cleaner', '~> 1.4'

  gem 'byebug'

  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'
end

# "is_active" links in views, and pagination
gem 'active_link_to'
gem 'will_paginate', '~> 3.0'

# Authentication and permissions
gem 'sorcery'
gem 'authority'

# Cron jobs
gem 'whenever'

# Rails 4 stuff!
gem 'activerecord-session_store'
gem 'responders', '~> 2.0'

gem 'chronic'
gem 'draper', '>= 1.4.0'
gem 'chartkick'
