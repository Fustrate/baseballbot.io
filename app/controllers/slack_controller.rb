# frozen_string_literal: true

class SlackController < ApplicationController
  before_action :verify_slack_signature

  # We don't need CSRF protection here
  protect_from_forgery with: :null_session

  def interactivity
    case payload.dig('actions', 0, 'name')
    when 'queue_action'
      Slack::ModQueueActionWorker.perform_async(payload)
    end

    render plain: '', status: 200
  end

  protected

  def verify_slack_signature
    Slack::VerifySignature.verify!(team_id: payload.dig('team', 'id'))
  end

  def payload
    @payload ||= JSON.parse(Current.params[:payload])
  end
end
