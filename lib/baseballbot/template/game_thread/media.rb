# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module Media
        def free_game?
          content.dig('media', 'freeGame')
        end

        def enhanced_game?
          content.dig('media', 'enhancedGame')
        end

        def away_tv
          tv_feeds
            .select { |item| %w[AWAY NATIONAL].include?(item['mediaFeedType']) }
            .map { |item| item['callLetters'] }
            .join(', ')
        end

        def home_tv
          tv_feeds
            .select { |item| %w[HOME NATIONAL].include?(item['mediaFeedType']) }
            .map { |item| item['callLetters'] }
            .join(', ')
        end

        def away_radio
          radio_feeds
            .select { |item| %w[AWAY NATIONAL].include?(item['type']) }
            .sort_by { |item| item['language'] == 'en' ? 0 : 1 }
            .map { |item| radio_name(item) }
            .join(', ')
        end

        def home_radio
          radio_feeds
            .select { |item| %w[HOME NATIONAL].include?(item['type']) }
            .sort_by { |item| item['language'] == 'en' ? 0 : 1 }
            .map { |item| radio_name(item) }
            .join(', ')
        end

        def home_pitcher_notes
          schedule_data.dig(
            'dates', 0, 'games', 0, 'teams', 'home', 'probablePitcher', 'note'
          )
        end

        def away_pitcher_notes
          schedule_data.dig(
            'dates', 0, 'games', 0, 'teams', 'away', 'probablePitcher', 'note'
          )
        end

        protected

        def tv_feeds
          @tv_feeds ||= media_with_title('MLBTV')
        end

        def radio_feeds
          @radio_feeds ||= media_with_title('Audio')
        end

        def media_with_title(title)
          content.dig('media', 'epg')
            &.detect { |media| media['title'] == title }
            &.fetch('items') || []
        end

        def radio_name(item)
          return item['callLetters'] if item['language'] == 'en'

          "#{item['callLetters']} (#{item['language'].upcase})"
        end
      end
    end
  end
end
