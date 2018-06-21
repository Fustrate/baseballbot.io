# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BaseballbotIo
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Set Time.zone default to the specified zone and make Active Record
    # auto-convert to this zone. Run "rake -D time" for a list of tasks for
    # finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'
    config.active_record.default_timezone = :local

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0
  end
end
