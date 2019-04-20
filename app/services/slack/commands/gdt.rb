# frozen_string_literal: true

module Slack
  module Commands
    class GDT < ApplicationService
      POSTGAME_STATUSES = /Final|Game Over|Postponed|Completed Early/.freeze

      def call
        # params[:command] => '/gdt
        # params[:text] => 'add angels 4/19'

        command, args = params[:text].split(' ', 2)

        case command
        when 'add' then add_gdt(args)
        when 'list' then list_gdt(args)
        else
          '???'
        end
      end

      protected

      def add_gdt(text)
        case text
        when /free(?: game)?(?<date> .*)?/ then add_free_game(Regexp.last_match)
        when /\A\d{6}\z/ then add_game_by_pk(text.to_i)
        else
          'Only free games are supported so far.'
        end
      end

      def list_gdt(_text)
        'listing upcoming gdts'
      end

      def add_free_game(args)
        free_games = find_games(args[:date])
          .select { |game| game.dig('content', 'media', 'freeGame') }

        return 'There is more than one free game.' if free_games.count > 1
        return 'There are no free games.' if free_games.none?

        add_game_by_pk free_games.dig(0, 'gamePk')
      end

      def add_game_by_pk(game_pk, title = nil)
        live_feed = api.live_feed(game_pk)

        return 'Invalid game PK' unless live_feed

        status = live_feed.game_data.dig('status', 'abstractGameState')

        return 'Cannot add finished game' if POSTGAME_STATUSES.match?(status)

        home_team = live_feed.dig('gameData', 'teams', 'home', 'teamName')
        away_team = live_feed.dig('gameData', 'teams', 'away', 'teamName')

        date = Time.zone
          .parse(live_feed.dig('gameData', 'datetime', 'dateTime'))
          .in_time_zone(ActiveSupport::TimeZone.new('America/New_York'))
          .strftime('%-m/%-d at %-I:%m %p')

        "Adding #{away_team} @ #{home_team} on #{date} to the list"
      end

      def find_games(text)
        date = text && text != 'today' ? Chronic.parse(text) : Time.zone.today

        api.schedule(
          sportId: 1,
          date: date.strftime('%m/%d/%Y'),
          eventTypes: 'primary',
          scheduleTypes: 'games'
        ).dig('dates', 0, 'games') || []
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
