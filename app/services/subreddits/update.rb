# frozen_string_literal: true

module Subreddits
  class Update < ApplicationService
    def call(subreddit)
      @subreddit = subreddit

      # Eventually the whole options hash will be assigned at once instead of this piecemeal method
      update_game_thread_settings
      update_pregame_settings
      update_postgame_settings
      update_off_day_settings

      @subreddit.save!
    end

    protected

    def update_game_thread_settings
      @subreddit.options['game_threads'] ||= {}
      @subreddit.options['game_threads']['sticky_comment'] = params.dig(:subreddit, :game_threads, :sticky_comment)
    end

    def update_pregame_settings
      @subreddit.options['pregame'] ||= {}
      @subreddit.options['pregame']['sticky_comment'] = params.dig(:subreddit, :pregame, :sticky_comment)
    end

    def update_postgame_settings
      @subreddit.options['postgame'] ||= {}
      @subreddit.options['postgame']['sticky_comment'] = params.dig(:subreddit, :postgame, :sticky_comment)
    end

    def update_off_day_settings
      @subreddit.options['off_day'] ||= {}
      @subreddit.options['off_day']['sticky_comment'] = params.dig(:subreddit, :off_day, :sticky_comment)
    end
  end
end
