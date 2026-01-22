# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)

require 'rake'

require 'rspec/rails'

Rails.application.load_tasks

# The following line is provided for convenience purposes. It has the downside of increasing the boot-up time by
# auto-requiring all files in the support directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
Rails.root.glob('spec/support/**/*.rb').each { require it }

# Checks for pending migrations and applies them before tests are run.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_paths = [Rails.root.join('spec/fixtures')]

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods

  config.before { Current.reset }
end
