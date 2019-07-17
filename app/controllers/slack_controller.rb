# frozen_string_literal: true

class SlackController < ApplicationController
  before_action :verify_slack_signature

  # We don't need CSRF protection here
  protect_from_forgery with: :null_session

  def interactivity
    case params.dig(:actions, 0, :name)
    when 'queue_action'
      # Slack::ModQueueActionWorker.perform_async(params)
    end

    render plain: 'OK', status: 200
  end

  protected

  def verify_slack_signature
    raise 'Invalid signature' unless Slack::VerifySignature.valid?
  end
end