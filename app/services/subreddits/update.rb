# frozen_string_literal: true

module Subreddits
  class Update < ApplicationService
    def call(subreddit)
      @subreddit = subreddit
      @options = params.dig(:subreddit, :options) || {}

      # Eventually the whole options hash will be assigned at once instead of this piecemeal method
      update_game_thread_settings
      update_pregame_settings
      update_postgame_settings
      update_off_day_settings

      @subreddit.options.compact!

      @subreddit.save!
    end

    protected

    def update_game_thread_settings
      @subreddit.options['game_threads'] ||= {}
      @subreddit.options['game_threads']['sticky_comment'] = @options.dig(:game_threads, :sticky_comment)

      @subreddit.options['game_threads'].compact!
    end

    def update_pregame_settings
      @subreddit.options['pregame'] ||= {}
      @subreddit.options['pregame']['sticky_comment'] = @options.dig(:pregame, :sticky_comment)

      @subreddit.options['pregame'].compact!
    end

    def update_postgame_settings
      @subreddit.options['postgame'] ||= {}
      @subreddit.options['postgame']['sticky_comment'] = @options.dig(:postgame, :sticky_comment)

      @subreddit.options['postgame'].compact!
    end

    def update_off_day_settings
      @subreddit.options['off_day'] ||= {}
      @subreddit.options['off_day']['sticky_comment'] = @options.dig(:off_day, :sticky_comment)

      @subreddit.options['off_day'].compact!
    end
  end
end
