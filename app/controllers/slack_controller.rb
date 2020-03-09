# frozen_string_literal: true

class SlackController < ApplicationController
  before_action :verify_slack_signature

  # We don't need CSRF protection here
  protect_from_forgery with: :null_session

  def interactivity
    action = payload.dig('actions', 0)

    if action['name'] == 'queue_action'
      Slack::ModQueueActionJob.perform_later payload
    elsif action['action_id'] == 'add_game'
      Slack::AddGameJob.perform_later payload
    end

    render json: modified_message, status: 200
  end

  protected

  def verify_slack_signature
    Slack::VerifySignature.verify!(team_id: payload.dig('team', 'id'))
  end

  def payload
    @payload ||= JSON.parse(Current.params[:payload])
  end

  def modified_message
    message = payload['original_message']

    message['attachments'][-1].delete 'actions'

    message
  end
end
