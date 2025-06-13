# frozen_string_literal: true

module Subreddits
  class Update < ApplicationService
    def call(subreddit)
      @subreddit = subreddit
      @options = params.dig(:subreddit, :options) || {}

      @subreddit.options.deep_merge!(all_settings)

      deep_compact_hash! @subreddit.options

      @subreddit.save!
    end

    protected

    def all_settings
      {
        'game_threads' => game_thread_settings,
        'pregame' => pregame_settings,
        'postgame' => postgame_settings,
        'off_day' => off_day_settings,
        'sidebar' => sidebar_settings,
        'general' => general_settings
      }
    end

    def game_thread_settings
      {
        'sticky_comment' => @options.dig(:game_threads, :sticky_comment)
        # enabled: boolean_value(@options.dig(:game_threads, :enabled))
        # flair_id: {won,default,lost}
        # post_at: integer/string
        # sticky: boolean_value(@options.dig(:game_threads, :sticky))
        # title: {postseason,default,wildcard}
      }
    end

    def pregame_settings
      {
        'sticky_comment' => @options.dig(:pregame, :sticky_comment)
        # enabled: boolean_value(@options.dig(:pregame, :enabled))
        # flair_id: string
        # post_at: integer/string
        # sticky: boolean_value(@options.dig(:pregame, :sticky))
        # title: {default,postseason}
      }
    end

    def postgame_settings
      {
        'sticky_comment' => @options.dig(:postgame, :sticky_comment)
        # enabled: boolean_value(@options.dig(:postgame, :enabled))
        # flair_id: {default,won,lost}
        # sticky: boolean_value(@options.dig(:postgame, :sticky))
        # title: {default,won,lost,postseason}
      }
    end

    def off_day_settings
      {
        'sticky_comment' => @options.dig(:off_day, :sticky_comment)
        # enabled: boolean_value(@options.dig(:off_day, :enabled))
        # flair_id: string
        # post_at: integer/string
        # sticky: boolean_value(@options.dig(:off_day, :sticky))
        # title: string
      }
    end

    def sidebar_settings
      {
        # enabled: boolean_value(@options.dig(:sidebar, :enabled))
      }
    end

    def general_settings
      {
        # 'sticky_slot' => ([1, 2] & [@options[:sticky_slot]&.to_i]).first
      }
    end

    # The options hash is just a hash of hashes and string/integers/booleans, no need to test for arrays at this time
    def deep_compact_hash!(value)
      return unless value.is_a?(Hash)

      value.transform_values! { deep_compact_hash!(it) }

      value.compact!
    end

    def boolean_value(value) = ActiveRecord::Type::Boolean.new.cast(value || false)
  end
end
