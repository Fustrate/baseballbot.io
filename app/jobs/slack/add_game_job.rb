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

      case setting
      when /\A-?\d{1,2}\z/                 then starts_at - Regexp.last_match[0].to_i.abs * 3600
      when /(1[012]|\d)(:\d\d|) ?(am|pm)/i then constant_time(Regexp.last_match)
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
      @starts_at ||= Time.zone.parse(game_feed.dig('gameData', 'datetime', 'dateTime'))
        .in_time_zone(ActiveSupport::TimeZone.new('America/Los_Angeles'))
    end

    def api
      @api ||= MLBStatsAPI::Client.new(
        logger: Rails.logger,
        cache: Rails.application.redis
      )
    end
  end
end
