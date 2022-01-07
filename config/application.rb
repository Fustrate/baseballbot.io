# frozen_string_literal: true

require_relative 'boot'

require 'rails'

# We don't use ActionCable, Sprockets, or TestUnit
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
# require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require 'action_mailbox/engine'
# require 'action_text/engine'
require 'action_view/railtie'
# require 'action_cable/engine'
# require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BaseballbotIo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    # These configuration options cannot be put in an initializer - they're run too late in the
    # initialization process to have any effect.
    config.time_zone = 'Pacific Time (US & Canada)'
    config.active_record.default_timezone = :local
  end
end
