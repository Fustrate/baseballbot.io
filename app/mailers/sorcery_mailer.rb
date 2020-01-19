# frozen_string_literal: true

class SorceryMailer < ApplicationMailer
  def activation_needed_email(account)
    # @activation_url = activate_url(account.activation_token)

    mail to: account.email, subject: t('sessions.activation.email_subject')
  end

  def reset_password_email(account)
    # @reset_url = reset_password_url(account.reset_password_token)

    mail to: account.email, subject: t('sessions.reset_password.email_subject')
  end

  def send_unlock_token_email(account)
    # @unlock_url = unlock_url(account.unlock_token)

    mail to: account.email, subject: t('sessions.unlock.email_subject')
  end
end
