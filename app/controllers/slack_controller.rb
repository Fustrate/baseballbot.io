# frozen_string_literal: true

class SlackController < ApplicationController
  before_action :verify_slack_signature

  # We don't need CSRF protection here
  protect_from_forgery with: :null_session

  def interactivity
    if action['name'] == 'queue_action'
      Slack::ModQueueActionJob.perform_later payload
    elsif action['action_id'] == 'add_game'
      Slack::AddGameJob.perform_later payload
    end

    render json: modified_message, status: :ok
  end

  protected

  def verify_slack_signature
    Slack::VerifySignature.verify!(team_id: payload.dig('team', 'id'))
  end

  def payload
    @payload ||= JSON.parse(Current.params[:payload])
  end

  def action
    @action ||= payload.dig('actions', 0)
  end

  def modified_message
    if action['name'] == 'queue_action'
      message = payload['original_message']

      message['attachments'][-1].delete 'actions'

      message
    elsif action['action_id'] == 'add_game'
      { response_type: 'ephemeral', text: 'Processing...' }
    else
      { text: 'Processing error. Please try again or let Fustrate know.' }
    end
  end
end
