# frozen_string_literal: true

module Slack
  class ModQueueActionJob < ApplicationJob
    queue_as :slack

    def perform(*args)
      @payload = args

      @action = @payload.dig('actions', 0, 'selected_options', 0, 'value')

      send_to_reddit
    end

    protected

    def send_to_reddit
      reddit.client.access = Account.find_by(name: 'DodgerBot').access

      subreddit = reddit.subreddit('dodgers')
      submission = subreddit.load_submission(id: POST_ID)

      response = case @action
                 when 'spam' then submission.remove(spam: true)
                 when 'approve' then submission.approve
                 end

      raise response.raw_body unless response.code == 200

      send_to_slack
    end

    def send_to_slack
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
        ":hocho: Marked as spam by *@#{@payload.dig('user', 'name')}*"
      when 'approve'
        ":white_check_mark: Approved by *@#{@payload.dig('user', 'name')}*"
      end
    end

    def reddit
      @reddit ||= Redd.it(
        user_agent: 'DodgerBot Slack Mod Queue by /u/Fustrate',
        client_id: Rails.application.credentials.dig(:reddit, :client_id),
        secret: Rails.application.credentials.dig(:reddit, :secret)
      )
    end
  end
end
