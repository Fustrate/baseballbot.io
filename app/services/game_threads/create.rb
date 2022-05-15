# frozen_string_literal: true

module GameThreads
  class Create < ApplicationService
    PERMITTED_PARAMS = %i[subreddit_id title game_pk].freeze

    def call
      @game_thread = GameThread.build_from_params(PERMITTED_PARAMS, status: 'Future')

      authorize! :create, @game_thread

      @game_thread.starts_at = game_starts_at
      @game_thread.post_at = @game_thread.starts_at - (params[:hours]&.to_i || 1).hours

      @game_thread.events.new type: 'Created', user: Current.user

      @game_thread.save!

      @game_thread
    end

    def game_starts_at
      utc_timestamp = ::MLBStatsAPI::Client.new(logger: Rails.logger, cache: Rails.application.redis)
        .live_feed(@game_thread.game_pk)
        .dig('gameData', 'datetime', 'dateTime')

      ::Time.zone.parse(utc_timestamp).in_time_zone('America/Los_Angeles')
    end
  end
end
