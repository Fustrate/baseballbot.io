# frozen_string_literal: true

module Slack
  module Commands
    class GDT < ApplicationService
      POSTGAME_STATUSES = /Final|Game Over|Postponed|Completed Early/.freeze

      TEAM_TO_ID = {
        T0KEXQR25: 15
      }.freeze

      def call
        # params[:command] => '/gdt
        # params[:text] => 'add angels 4/19'
        # params[:team_id] => 'T0KEXQR25',
        # params[:team_domain] => 'r-baseball-mods',
        # params[:channel_id] => 'C6H05DDS9',
        # params[:channel_name] => 'bot',
        # params[:user_id] => 'U0KF8ULV7',
        # params[:user_name] => 'fustrate'

        command, args = params[:text].split(' ', 2)

        case command
        when 'add' then add_gdt(args)
        # when 'list' then list_gdt(args)
        else
          text_response '???'
        end
      end

      protected

      def text_response(text)
        { response_type: 'in_channel', text: text }
      end

      def subreddit_id
        TEAM_TO_ID[params[:team_id].to_sym]
      end

      def add_gdt(_text)
        games = find_games(args[:date]).reject do |game|
          POSTGAME_STATUSES.match?(game['status']['abstractGameState'])
        end

        modal_response(games.map { |game| game_option(game) })
      end

      def game_option(game)
        {
          text: {
            type: 'mrkdwn',
            text: game_title(game),
            emoji: true
          },
          value: game['gamePk']
        }
      end

      def game_title(game)
        away = game.dig('teams', 'away', 'team', 'abbreviation')
        home = game.dig('teams', 'home', 'team', 'abbreviation')
        free = game.dig('content', 'media', 'freeGame')
        time = Time.zone.parse(game['gameDate'])
          .in_time_zone(ActiveSupport::TimeZone.new('America/New_York'))
          .strftime('%-I:%m %p')

        "#{away} @ #{home} - #{time}#{free ? ' :free:' : ''}"
      end

      def modal_response(options)
        {
          type: 'modal',
          title: {
            type: 'plain_text',
            text: 'Add a GDT :baseball:',
            emoji: true
          },
          submit: {
            type: 'plain_text',
            text: 'Submit'
          },
          close: {
            type: 'plain_text',
            text: 'Cancel'
          },
          blocks: [
            {
              type: 'section',
              text: {
                type: 'mrkdwn',
                text: 'Select a game to add:'
              },
              accessory: {
                type: 'static_select',
                placeholder: {
                  type: 'plain_text',
                  text: 'Select an item',
                  emoji: true
                },
                options: options
              }
            }
          ]
        }
      end

      # def add_game_by_pk(game_pk)
      #   live_feed = api.live_feed(game_pk)

      #   return 'Invalid game PK' unless live_feed

      #   status = live_feed.game_data.dig('status', 'abstractGameState')

      #   return 'Cannot add finished game' if POSTGAME_STATUSES.match?(status)

      #   home_team = live_feed.game_data.dig('teams', 'home', 'teamName')
      #   away_team = live_feed.game_data.dig('teams', 'away', 'teamName')
      #   date = game_date(live_feed).strftime('%-m/%-d at %-I:%m %p')

      #   "Adding #{away_team} @ #{home_team} on #{date} to the list"
      # end

      # def game_date(live_feed, time_zone: 'America/New_York')
      #   Time.zone
      #     .parse(live_feed.game_data.dig('datetime', 'dateTime'))
      #     .in_time_zone(ActiveSupport::TimeZone.new(time_zone))
      #     .strftime('%-m/%-d at %-I:%m %p')
      # end

      def find_games(text)
        api.schedule(
          sportId: 1,
          date: parse_date(text).strftime('%m/%d/%Y'),
          eventTypes: 'primary',
          scheduleTypes: 'games',
          hydrate: 'game(content(summary)),team'
        ).dig('dates', 0, 'games') || []
      end

      def parse_date(text)
        return Time.zone.today if text == 'today'

        Chronic.parse(text)
      end

      def api
        @api ||= MLBStatsAPI::Client.new(
          logger: Rails.logger,
          cache: Rails.application.redis
        )
      end
    end
  end
end
