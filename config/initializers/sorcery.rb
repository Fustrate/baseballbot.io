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
    user.stretches = 1 if Rails.env.test?

    # --------------------------------------------------------------------------
    # Core
    # --------------------------------------------------------------------------

    user.username_attribute_names = %i[username email]
    user.downcase_username_before_authenticating = true

    # --------------------------------------------------------------------------
    # Remember Me
    # --------------------------------------------------------------------------

    user.remember_me_for = 14.days

    # --------------------------------------------------------------------------
    # Activation
    # --------------------------------------------------------------------------

    user.user_activation_mailer = SorceryMailer
    user.activation_needed_email_method_name = :activation_needed_email
    user.activation_success_email_method_name = nil
    user.prevent_non_active_users_to_login = true
    user.activation_token_expiration_period = 7.days

    # --------------------------------------------------------------------------
    # Reset Password
    # --------------------------------------------------------------------------

    user.reset_password_mailer = SorceryMailer
    user.reset_password_email_method_name = :reset_password_email
    user.reset_password_expiration_period = 24.hours
    user.reset_password_time_between_emails = 5.minutes

    # --------------------------------------------------------------------------
    # Brute Force Protection
    # --------------------------------------------------------------------------

    user.unlock_token_mailer = SorceryMailer
    user.unlock_token_email_method_name = :send_unlock_token_email
    user.consecutive_login_retries_amount_limit = 10
    user.login_lock_time_period = 60.minutes
  end

  config.user_class = 'User'
end
