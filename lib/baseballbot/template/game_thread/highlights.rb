# frozen_string_literal: true

class Baseballbot
  module Template
    class GameThread
      module Highlights
        def highlights
          return [] unless started?

          @highlights ||= content.dig('highlights', 'highlights', 'items')
            &.sort_by { |media| media['date'] }
            &.map { |media| process_media(media) }
            &.compact || []
        end

        def highlights_list
          highlights
            .map do |highlight|
              # icon = link_to '', url: "/#{highlight[:code]}"
              text = "#{highlight[:blurb]} (#{highlight[:duration]})"
              url = highlight[:hd]

              "- #{url ? link_to(text, url: url) : text}"
            end
            .join "\n"
        end

        def highlights_table
          lines = highlights.map do |highlight|
            [
              # link_to('', url: "/#{highlight[:code]}"),
              highlight[:blurb],
              highlight[:duration],
              link_to('HD', url: highlight[:hd])
            ].join('|')
          end

          <<~HIGHLIGHTS
            Description|Length|HD
            -|-|-
            #{lines.join("\n")}
          HIGHLIGHTS
        end

        protected

        def hd_playback_url(media)
          media['playbacks']
            .find { |video| video['name'] == 'mp4Avc' }
            &.dig('url')
        end

        def process_media(media)
          return unless media['type'] == 'video'

          {
            # code: media_team_code(media),
            headline: media['headline'].strip,
            blurb: media['blurb'].strip.gsub(/^[A-Z@]+: /, ''),
            duration: media['duration'].strip.gsub(/^00:0?/, ''),
            # sd: playback(media, 'FLASH_1200K_640X360'),
            hd: hd_playback_url(media)
          }
        end

        def media_team_code(media)
          media.dig('image', 'title')&.match(/^\d+([a-z]+)/i)&.captures&.first
        end
      end
    end
  end
end
