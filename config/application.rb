# frozen_string_literal: true

require_relative 'boot'

require 'rails'

require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'active_job/railtie'
require 'active_record/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BaseballbotIo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Add any other `lib` subdirectories that do not contain `.rb` files, or that should not be reloaded or eager
    # loaded. Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[tasks yarn])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    # These configuration options cannot be put in an initializer - they're run
    # too late in the initialization process to have any effect.
    config.time_zone = 'Pacific Time (US & Canada)'
    config.active_record.default_timezone = :local

    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end
