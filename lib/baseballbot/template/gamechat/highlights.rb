# frozen_string_literal: true

class Baseballbot
  module Template
    class Gamechat
      module Highlights
        def highlights
          return [] unless started?

          content.dig('highlights', 'live', 'items')
            .sort_by { |media| media['id'] }
            .map { |media| process_media(media) }
            .compact
        end

        def highlights_list
          highlights
            .map do |highlight|
              icon = link_to '', url: "/#{highlight[:team].code}"
              text = "#{highlight[:blurb]} (#{highlight[:duration]})"
              url = highlight[:hd]

              "- #{icon} #{url ? link_to(text, url: url) : text}"
            end
            .join "\n"
        end

        protected

        def playback(media, name)
          media['playbacks'].find { |video| video['name'] == name }&.dig('url')
        end

        def process_media(media)
          return unless media['type'] == 'video'

          team_id = media['keywordsDisplay']
            .find { |keyword| keyword['type'] == 'team_id' }
            &.dig('value')

          {
            team: team_id.to_i == team.id ? team : opponent,
            headline: media['headline'].strip,
            blurb: media['blurb'].strip.gsub(/^[A-Z@]+: /, ''),
            duration: media['duration'].strip.gsub(/^00:0?/, ''),
            sd: playback(media, 'FLASH_1200K_640X360'),
            hd: playback(media, 'FLASH_2500K_1280X720')
          }
        end
      end
    end
  end
end
