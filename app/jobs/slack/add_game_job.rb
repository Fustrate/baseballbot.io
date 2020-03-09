# frozen_string_literal: true

module Slack
  class AddGameJob < ApplicationJob
    queue_as :slack

    def perform(payload)
      @payload = payload

      @game_pk = @payload.dig('actions', 0, 'selected_option', 'value').to_i

      add_game_thread!
      notify_slack!(modified_message)
    rescue ActiveRecord::RecordNotUnique
      notify_slack!(already_added_message)
    end

    protected

    def notify_slack!(message)
      uri = URI.parse(@payload['response_url'])

      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true

      req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
      req.body = message.to_json

      res = https.request(req)

      return if res.code.to_i == 200

      raise "Invalid response code: #{res.code}"
    end

    def already_added_message
      {
        replace_original: true,
        text: 'This game has already been added.'
      }
    end

    def modified_message
      {
        replace_original: true,
        text: success_message
      }
    end

    def success_message
      format(
        'Added GDT for %<away>s @ %<home>s on %<date>s',
        away: game_feed.game_data.dig('teams', 'away', 'teamName'),
        home: game_feed.game_data.dig('teams', 'home', 'teamName'),
        date: starts_at.strftime('%A, %B %-d %Y')
      )
    end

    def subreddit
      @subreddit ||= Subreddit.find_by slack_id: @payload.dig('team', 'id')
    end

    def post_at
      setting = subreddit.options.dig('game_threads', 'post_at')

      if setting =~ /\A\-?\d{1,2}\z/
        starts_at - Regexp.last_match[0].to_i.abs * 3600
      elsif setting =~ /(1[012]|\d)(:\d\d|) ?(am|pm)/i
        constant_time(Regexp.last_match)
      else
        # Default to 3 hours before game time
        starts_at - 3 * 3600
      end
    end

    def constant_time(match_data)
      hours = match_data[1].to_i
      hours += 12 if hours != 12 && match_data[3].casecmp('pm').zero?
      minutes = (match_data[2] || ':00')[1..2].to_i

      starts_at.change(hour: hours, min: minutes)
    end

    def add_game_thread!
      subreddit.game_threads.create!(
        starts_at: starts_at,
        post_at: post_at,
        status: 'Future',
        game_pk: @game_pk
      )
    end

    def game_feed
      @game_feed ||= api.live_feed @game_pk
    end

    def starts_at
      @starts_at ||= begin
        Time.zone.parse(game_feed.dig('gameData', 'datetime', 'dateTime'))
          .in_time_zone(ActiveSupport::TimeZone.new('America/Los_Angeles'))
      end
    end

    def api
      @api ||= MLBStatsAPI::Client.new(
        logger: Rails.logger,
        cache: Rails.application.redis
      )
    end
  end
end

# {
#   "type":"block_actions",
#   "team":{
#     "id":"T0KEXQR25",
#     "domain":"r-baseball-mods"
#   },
#   "user":{
#     "id":"U0KF8ULV7",
#     "username":"fustrate",
#     "name":"fustrate",
#     "team_id":"T0KEXQR25"
#   },
#   "api_app_id":"ADBGRAAMR",
#   "token":"M7wcz5wHhPXTkAUEHBdTxfTN",
#   "container":{
#     "type":"message",
#     "message_ts":"1583729964.000900",
#     "channel_id":"C6H05DDS9",
#     "is_ephemeral":true
#   },
#   "trigger_id":"988418660176.19507841073.a93ce30ccb8227ff8c3cb55768c70922",
#   "channel":{
#     "id":"C6H05DDS9",
#     "name":"bot"
#   },
#   "response_url":"https://hooks.slack.com/actions/T0KEXQR25/990282505783/dDnznnpw9GNHqqGcEwdUDpMi",
#   "actions":[
#     {
#       "confirm":{
#         "title":{"type":"plain_text","text":"Are you sure you want to add this game?","emoji":true},
#         "text":{"type":"plain_text","text":"Are you sure?","emoji":true},
#         "confirm":{"type":"plain_text","text":"Yes, add it","emoji":true},
#         "deny":{"type":"plain_text","text":"Nevermind","emoji":true}
#       },
#       "type":"static_select",
#       "action_id":"add_game",
#       "block_id":"9xqzF",
#       "selected_option":{
#         "text":{
#           "type":"plain_text",
#           "text":"NYM @ MIA - 1:05 PM",
#           "emoji":true
#         },
#         "value":"605124"
#       },
#       "placeholder":{
#         "type":"plain_text",
#         "text":"Select an item",
#         "emoji":true
#       },
#       "action_ts":"1583730311.728869"
#     }
#   ]
# }
