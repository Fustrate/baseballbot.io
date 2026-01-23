# frozen_string_literal: true

module Subreddits
  class Update < ApplicationService
    GUID_FORMAT = /\A(?<id>\h{8}-\h{4}-\h{4}-\h{4}-\h{12})\z/

    SETTINGS = {
      game_threads: {
        enabled: [:boolean],
        sticky_comment: [:string],
        post_at: [
          :string,
          in: %w[-1 -2 -3 -4 -5 -6 -7 -8 -9 -10 -11 -12 1:00 2:00 3:00 4:00 5:00 6:00 7:00 8:00 9:00 10:00 11:00 12:00],
          required: true
        ],
        sticky: [:boolean],
        flair_id: [:guid],
        title: [:string],
        'title.postseason': [:string]
      },
      pregame: {
        enabled: [:boolean],
        sticky_comment: [:string],
        post_at: [
          :string,
          in: %w[-1 -2 -3 -4 -5 -6 -7 -8 -9 -10 -11 -12 1:00 2:00 3:00 4:00 5:00 6:00 7:00 8:00 9:00 10:00 11:00 12:00],
          required: true
        ],
        sticky: [:boolean],
        flair_id: [:guid],
        title: [:string],
        'title.postseason': [:string]
      },
      postgame: {
        enabled: [:boolean],
        sticky_comment: [:string],
        sticky: [:boolean],
        flair_id: [:guid],
        'flair_id.postseason': [:guid],
        'flair_id.won': [:guid],
        'flair_id.lost': [:guid],
        title: [:string],
        'title.postseason': [:string],
        'title.won': [:string],
        'title.lost': [:string]
      },
      off_day: {
        enabled: [:boolean],
        sticky_comment: [:string],
        sticky: [:boolean],
        flair_id: [:guid],
        post_at: [:string, in: %w[1:00 2:00 3:00 4:00 5:00 6:00 7:00 8:00 9:00 10:00 11:00 12:00], required: true],
        title: [:string, required: true]
      },
      sidebar: {
        enabled: [:boolean]
      },
      general: {
        sticky_slot: [:integer, in: [1, 2], default: 1]
      }
    }.freeze

    def call(subreddit)
      @subreddit = subreddit
      @options = params.dig(:subreddit, :options) || {}

      # Create a working copy with indifferent access
      @working_options = ActiveSupport::HashWithIndifferentAccess.new(@subreddit.options || {})

      update_settings

      # Assign the modified options back to the subreddit
      @subreddit.options = deep_compact_hash(@working_options)

      Subreddits::LogEdit.call @subreddit

      @subreddit.save!
    end

    protected

    def update_settings
      SETTINGS.each do |category, category_settings|
        next unless @options.key?(category)

        @working_options[category] ||= {}.with_indifferent_access

        category_settings.each do |key, (type, options)|
          next unless @options[category]&.key?(key)

          case type
          when :string then update_string_value(category, key, **options)
          when :boolean then update_boolean_value(category, key)
          when :guid then update_guid_value(category, key)
          when :integer then update_integer_value(category, key, **options)
          end
        end

        # Check for required fields after all updates in this category
        validate_required_fields(category, category_settings) if @working_options[category]['enabled']
      end
    end

    def update_string_value(category, key, **options)
      value = @options.dig(category, key)&.to_s&.strip

      if value.present? && options[:in]&.exclude?(value)
        raise ArgumentError, "#{category}.#{key} must be one of #{options[:in].join(', ')}"
      end

      @working_options[category][key] = value.presence
    end

    def update_boolean_value(category, key)
      value = @options.dig(category, key)

      @working_options[category][key] = ActiveRecord::Type::Boolean.new.cast(value || false)
    end

    def update_guid_value(category, key)
      value = @options.dig(category, key)&.to_s&.strip

      raise ArgumentError, "#{category}.#{key} must be a GUID" if value.present? && !GUID_FORMAT.match?(value)

      @working_options[category][key] = value.presence
    end

    def update_integer_value(category, key, **options)
      value = @options.dig(category, key)&.to_i

      if options[:in] && value && options[:in].exclude?(value)
        raise ArgumentError, "#{category}.#{key} must be one of #{options[:in].join(', ')}"
      end

      @working_options[category][key] = value || options[:default]
    end

    def validate_required_fields(category, category_settings)
      category_settings.each do |key, config_array|
        _, *options_hash = config_array

        options = options_hash.first || {}

        next unless options[:required]

        value = @working_options[category][key]

        raise ArgumentError, "#{category}.#{key} is required" if value.blank?
      end
    end

    # The options hash is just a hash of hashes and string/integers/booleans, no need to test for arrays at this time
    def deep_compact_hash(value)
      return value unless value.is_a?(Hash)

      value.transform_values! { deep_compact_hash(it) }

      value.compact
    end
  end
end
