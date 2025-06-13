# frozen_string_literal: true

source 'https://rubygems.org'

ruby file: '.ruby-version'

# Rails! [https://github.com/rails/rails]
gem 'rails', '~> 8.0.1'

# Postgres database [https://github.com/ged/ruby-pg]
gem 'pg', '~> 1.5'

# HAML templates instead of ERB [https://github.com/haml/haml-rails]
gem 'haml-rails', '~> 2.1'

# JSON generation with a nice DSL [https://github.com/rails/jbuilder]
gem 'jbuilder', '~> 2.11'

# Postcss integration with Rails [https://github.com/rails/cssbundling-rails]
gem 'cssbundling-rails', '~> 1.3'

# Esbuild integration with Rails [https://github.com/rails/jsbundling-rails]
gem 'jsbundling-rails', '~> 1.2'

# New Rails asset pipeline [https://github.com/rails/propshaft]
gem 'propshaft', '~> 1.1'

# Faster raw json generation [https://github.com/ohler55/oj]
gem 'oj', '~> 3.16'

# A few custom services and initializers [https://github.com/Fustrate/unary_plus]
gem 'unary_plus', '~> 0.8', github: 'Fustrate/unary_plus'

# Use Puma as the app server [https://github.com/puma/puma]
gem 'puma', '~> 6.3'

# Fetch data from the MLB Stats API [https://github.com/Fustrate/mlb_stats_api]
gem 'mlb_stats_api', '~> 0.2', github: 'Fustrate/mlb_stats_api'

# Reddit interaction [https://github.com/Fustrate/redd]
gem 'redd', '>= 0.9.0.pre.3', github: 'Fustrate/redd'

# App Monitoring [https://github.com/honeybadger-io/honeybadger-ruby]
gem 'honeybadger', '~> 5.2'

# Development evented file watcher [https://github.com/guard/listen]
gem 'listen', '~> 3.8'

# "is_active" links in views [https://github.com/comfy/active_link_to]
gem 'active_link_to', '~> 1.0'

# Pagination [https://github.com/ddnexus/pagy]
gem 'pagy', '~> 9.3'

# Authentication [https://github.com/Sorcery/sorcery]
gem 'sorcery', '~> 0.16'

# A more slim redis client [https://github.com/redis/redis-rb]
gem 'redis', '~> 5.0'

# Background Jobs [https://github.com/mperham/sidekiq]
gem 'sidekiq', '~> 8.0'

# ed25519 keys for deployment [https://github.com/RubyCrypto/ed25519]
gem 'ed25519', '~> 1.2'

# ed25519 keys for deployment [https://github.com/net-ssh/bcrypt_pbkdf-ruby]
gem 'bcrypt_pbkdf', '~> 1.1'

group :development do
  # Detect n+1 issues [https://github.com/flyerhzm/bullet]
  gem 'bullet', '~> 8.0'

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
  gem 'rubocop-rspec', '~> 3.6', require: false
end

group :development, :test do
  # Start debugger with binding.b [https://github.com/ruby/debug]
  gem 'debug', '~> 1.5'

  # Make RSpec play nicely with Rails [https://github.com/rspec/rspec-rails]
  gem 'rspec-rails', '~> 8.0'
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
  gem 'launchy', '~> 3.1'

  # Access assigns in controller & view tests [https://github.com/rails/rails-controller-testing]
  gem 'rails-controller-testing', '~> 1.0'

  # Use Cuprite for headless Chrome interaction [https://github.com/rubycdp/cuprite]
  # https://janko.io/upgrading-from-selenium-to-cuprite/
  gem 'cuprite', '~> 0.14'
end
