# frozen_string_literal: true

module Slack
  class ModQueueActionJob < ApplicationJob
    queue_as :slack

    def perform(payload)
      @payload = payload

      @action = @payload.dig('actions', 0, 'value')

      perform_reddit_action
    end

    protected

    def perform_reddit_action
      response = case @action
                 when 'approve' then submission.approve
                 when 'ignore' then submission.ignore_reports
                 when 'remove' then submission.remove(spam: false)
                 when 'spam' then submission.remove(spam: true)
                 end

      raise response.raw_body unless response.code == 200

      update_slack_message
    end

    def update_slack_message
      uri = URI.parse(@payload['response_url'])

      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true

      req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
      req.body = modified_message.to_json

      res = https.request(req)

      return if res.code.to_i == 200

      raise 'Uh oh!'
    end

    def modified_message
      message = @payload['original_message']

      message['attachments'][-1].delete 'actions'
      message['attachments'] << { text: text_for_action }

      message
    end

    def text_for_action
      case @action
      when 'spam'
        ":canned_food: *Marked as spam by @#{@payload.dig('user', 'name')}*"
      when 'approve'
        ":white_check_mark: *Approved by @#{@payload.dig('user', 'name')}*"
      when 'remove'
        ":hocho: *Removed by @#{@payload.dig('user', 'name')}*"
      when 'ignore'
        ":shrug: *Reports ignored by @#{@payload.dig('user', 'name')}*"
      end
    end

    def submission
      @client = Redd::APIClient.new redd_auth_strategy, limit_time: 0
      @session = Redd::Models::Session.new @client

      @client.access = Account.find_by(name: 'DodgerBot').access

      @session.from_ids(@payload['callback_id']).first
    end

    def redd_auth_strategy
      Redd::AuthStrategies::Web.new(
        client_id: Rails.application.credentials.dig(:reddit, :client_id),
        secret: Rails.application.credentials.dig(:reddit, :secret),
        redirect_uri: Rails.application.credentials.dig(:reddit, :redirect_uri),
        user_agent: 'DodgerBot Slack Mod Queue by /u/Fustrate'
      )
    end
  end
end
