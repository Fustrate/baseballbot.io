# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.1.2'

# Rails! [https://github.com/rails/rails]
gem 'rails', '~> 7.0.4'

# Postgres database [https://github.com/ged/ruby-pg]
gem 'pg', '~> 1.4'

# HAML templates instead of ERB [https://github.com/haml/haml-rails]
gem 'haml-rails', '~> 2.0'

# JSON generation with a nice DSL [https://github.com/rails/jbuilder]
gem 'jbuilder', '~> 2.11'

# Postcss integration with Rails [https://github.com/rails/cssbundling-rails]
gem 'cssbundling-rails', '~> 1.1'

# Esbuild integration with Rails [https://github.com/rails/jsbundling-rails]
gem 'jsbundling-rails', '~> 1.0'

# New Rails asset pipeline [https://github.com/rails/propshaft]
gem 'propshaft', '~> 0.6'

# Frontend routes [https://github.com/railsware/js-routes]
gem 'js-routes', '~> 2.2', require: false

# Faster raw json generation [https://github.com/ohler55/oj]
gem 'oj', '~> 3.13'

# A few custom services and initializers [https://github.com/Fustrate/fustrate-rails]
gem 'fustrate-rails', '~> 0.8', github: 'Fustrate/fustrate-rails'

# Use Puma as the app server [https://github.com/puma/puma]
gem 'puma', '~> 6.0'

# Fetch data from the MLB Stats API [https://github.com/Fustrate/mlb_stats_api]
gem 'mlb_stats_api', '~> 0.2', github: 'Fustrate/mlb_stats_api'

# Reddit interaction [https://github.com/Fustrate/redd]
gem 'redd', '>= 0.9.0.pre.3', github: 'Fustrate/redd'

# App Monitoring [https://github.com/honeybadger-io/honeybadger-ruby]
gem 'honeybadger', '~> 5.0'

# Development evented file watcher [https://github.com/guard/listen]
gem 'listen', '~> 3.7'

# "is_active" links in views [https://github.com/comfy/active_link_to]
gem 'active_link_to', '~> 1.0'

# Pagination [https://github.com/mislav/will_paginate]
gem 'will_paginate', '~> 3.3'

# Authentication [https://github.com/Sorcery/sorcery]
gem 'sorcery', '~> 0.16'

# A more slim redis client [https://github.com/redis/redis-rb]
gem 'redis', '~> 5.0'

# Communication with the Discord bot
gem 'em-hiredis', '~> 0.3'

# More communication with the Discord bot
gem 'eventmachine', '~> 1.2'

# Background Jobs [https://github.com/mperham/sidekiq]
gem 'sidekiq', '~> 7.0'

# Keep a record of completed jobs in Sidekiq [https://github.com/russ/sidekiq-history]
gem 'sidekiq-history', '~> 0.0.12', github: 'Fustrate/sidekiq-history'

group :development do
  # Detect n+1 issues [https://github.com/flyerhzm/bullet]
  gem 'bullet', '~> 7.0'

  # Access an IRB console on exception pages or by using `= console` in views [https://github.com/rails/web-console]
  gem 'web-console', '~> 4.2'

  # Deploy with Capistrano [https://github.com/capistrano/capistrano]
  gem 'capistrano', '~> 3.17', require: false

  # Capistrano Bundler integration [https://github.com/capistrano/bundler]
  gem 'capistrano-bundler', '~> 2.1', require: false

  # Capistrano Rails integration [https://github.com/capistrano/rails]
  gem 'capistrano-rails', '~> 1.6', require: false

  # Capistrano rbenv integration [https://github.com/capistrano/rbenv]
  gem 'capistrano-rbenv', '~> 2.2', require: false

  # Ruby code linting [https://github.com/rubocop/rubocop]
  gem 'rubocop', '~> 1.31', require: false

  # Rubocop - performance cops [https://github.com/rubocop/rubocop-performance]
  gem 'rubocop-performance', '~> 1.14', require: false

  # Rubocop - rails cops [https://github.com/rubocop/rubocop-rails]
  gem 'rubocop-rails', '~> 2.15', require: false

  # Rubocop - rspec cops [https://github.com/rubocop/rubocop-rspec]
  gem 'rubocop-rspec', '~> 2.12', require: false

  # Shopify Ruby LSP [https://github.com/Shopify/ruby-lsp]
  gem 'ruby-lsp', '~> 0.3', github: 'Shopify/ruby-lsp', require: false
end

group :development, :test do
  # Start debugger with binding.b [https://github.com/ruby/debug]
  gem 'debug', '~> 1.5'

  # Make RSpec play nicely with Rails [https://github.com/rspec/rspec-rails]
  gem 'rspec-rails', '~> 6.0'
end

group :test do
  # Adds the `have(n)` matcher [https://github.com/rspec/rspec-collection_matchers]
  gem 'rspec-collection_matchers', '~> 1.2'

  # Interact with forms in tests [https://github.com/teamcapybara/capybara]
  gem 'capybara', '~> 3.37'

  # Mock the redis server/client [https://github.com/sds/mock_redis]
  gem 'mock_redis', '~> 0.32'

  # Reset the database to a clean state after every test [https://github.com/DatabaseCleaner/database_cleaner]
  gem 'database_cleaner', '~> 2.0'

  # Mock models & relationships [https://github.com/thoughtbot/factory_bot_rails]
  gem 'factory_bot_rails', '~> 6.2'

  # Launch the code editor from backtraces [https://github.com/copiousfreetime/launchy]
  gem 'launchy', '~> 2.5'

  # Access assigns in controller & view tests [https://github.com/rails/rails-controller-testing]
  gem 'rails-controller-testing', '~> 1.0'

  # Easy installation and use of web drivers to run system tests with browsers [https://github.com/titusfortner/webdrivers]
  gem 'webdrivers', '~> 5.0'
end
