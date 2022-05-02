# frozen_string_literal: true

require 'sorcery/engine'

# Other available submodules are:
#   :http_basic_auth, :external, :reset_password, :user_activation, :brute_force_protection
Rails.application.config.sorcery.submodules = %i[remember_me activity_logging session_timeout]

# Here you can configure each submodule's features.
Rails.application.config.sorcery.configure do |config|
  config.session_timeout = 4.hours

  config.user_config do |user|
    user.stretches = 1 if Rails.env.test?

    # --------------------------------------------------------------------------
    # Core
    # --------------------------------------------------------------------------

    user.username_attribute_names = %i[username]
    user.downcase_username_before_authenticating = true

    # --------------------------------------------------------------------------
    # Remember Me
    # --------------------------------------------------------------------------

    user.remember_me_for = 14.days
  end

  config.user_class = 'User'
end
