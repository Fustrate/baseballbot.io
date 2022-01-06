# frozen_string_literal: true

module Slack
  module Commands
    class GDT < ApplicationService
      POSTGAME_STATUSES = /Final|Game Over|Postponed|Completed Early/

      MODAL_RESPONSE_ACCESSORY = {
        type: 'static_select',
        action_id: 'add_game',
        placeholder: { type: 'plain_text', text: 'Select an item', emoji: true },
        confirm: {
          title: { type: 'plain_text', text: 'Are you sure you want to add this game?' },
          confirm: { type: 'plain_text', text: 'Yes, add it' },
          deny: { type: 'plain_text', text: 'Nevermind' }
        }
      }.freeze

      def call
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
        { response_type: 'ephemeral', text: text }
      end

      def subreddit
        @subreddit ||= Subreddit.find_by slack_id: params[:team_id]
      end

      def add_gdt(args)
        date = parse_date(args)
        options = game_options(date)

        return modal_response(date, options) if options.any?

        text_response "There were no games found on #{date.strftime('%-m/%-d/%y')}"
      end

      def game_option(game)
        {
          text: {
            type: 'plain_text',
            text: game_title(game),
            emoji: true
          },
          value: game['gamePk'].to_s
        }
      end

      def game_title(game)
        away = game.dig('teams', 'away', 'team', 'abbreviation')
        home = game.dig('teams', 'home', 'team', 'abbreviation')
        free = game.dig('content', 'media', 'freeGame')
        time = Time.zone.parse(game['gameDate'])
          .in_time_zone(ActiveSupport::TimeZone.new('America/New_York'))
          .strftime('%-I:%M %p')

        "#{away} @ #{home} - #{time}#{free ? ' 🆓' : ''}"
      end

      def modal_response(_date, options)
        {
          blocks: [
            {
              type: 'section',
              text: { type: 'mrkdwn', text: 'Select a game to add:' },
              accessory: MODAL_RESPONSE_ACCESSORY.dup.merge(options:)
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

      def game_options(date)
        added = existing_game_pks(date)

        scheduled_games(date).filter_map do |game|
          game_option(game) unless added.include?(game['gamePk']) || game_over?(game)
        end
      end

      def game_over?(game)
        POSTGAME_STATUSES.match?(game['status']['abstractGameState'])
      end

      def scheduled_games(date)
        api.schedule(
          sportId: 1,
          date: date.strftime('%m/%d/%Y'),
          eventTypes: 'primary',
          scheduleTypes: 'games',
          hydrate: 'game(content(summary)),team'
        ).dig('dates', 0, 'games') || []
      end

      def existing_game_pks(date)
        subreddit.game_threads.where('DATE(starts_at) = ?', date.to_date).pluck(:game_pk)
      end

      def parse_date(text)
        return Time.zone.today if text.blank? || text == 'today'

        Chronic.parse(text) || Time.zone.today
      end

      def api
        @api ||= MLBStatsAPI::Client.new(logger: Rails.logger, cache: Rails.application.redis)
      end
    end
  end
end
