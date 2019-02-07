# frozen_string_literal: true

class SorceryMailer < ApplicationMailer
  def activation_needed_email(account)
    # load_homeowner_info(account)

    # @activation_url = activate_url(
    #   account.activation_token,
    #   host: @community&.domain || Rails.application.config.vmg_domain
    # )

    mail to: account.email, subject: t('sessions.activation.email_subject')
  end

  def reset_password_email(account)
    # load_homeowner_info(account)

    # @reset_url = reset_password_url(
    #   account.reset_password_token,
    #   host: @community&.domain || Rails.application.config.vmg_domain
    # )

    mail to: account.email, subject: t('sessions.reset_password.email_subject')
  end

  def send_unlock_token_email(account)
    # load_homeowner_info(account)

    # @unlock_url = unlock_url(
    #   account.unlock_token,
    #   host: @community&.domain || Rails.application.config.vmg_domain
    # )

    mail to: account.email, subject: t('sessions.unlock.email_subject')
  end

  # protected

  # def load_homeowner_info(account)
  #   @account = account

  #   owner = Websites::AccountsHomeowner.where(account_id: account.id)
  #     .joins(homeowner: :property)
  #     .find do |acct_homeowner|
  #       acct_homeowner.community.active && acct_homeowner.homeowner.current?
  #     end

  #   @community = owner&.community

  #   @community_name = @community&.short_name || 'Valencia Management Group'
  # end
end
