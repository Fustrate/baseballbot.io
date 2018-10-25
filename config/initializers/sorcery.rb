# frozen_string_literal: true

require 'sorcery/engine'

# Other available submodules are:
#   :user_activation, :http_basic_auth, :external
Rails.application.config.sorcery.submodules = %i[
  remember_me reset_password activity_logging brute_force_protection
  session_timeout
]

# Here you can configure each submodule's features.
Rails.application.config.sorcery.configure do |config|
  config.session_timeout = 4.hours

  config.user_config do |user|
    user.username_attribute_names = %i[username email]
    user.downcase_username_before_authenticating = true
    user.remember_me_for = 14.days

    user.stretches = 1 if Rails.env.test?
  end

  config.user_class = 'User'
end
