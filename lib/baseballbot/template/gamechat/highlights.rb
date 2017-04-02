# frozen_string_literal: true

class Baseballbot
  module Template
    class Gamechat
      module Highlights
        def highlights
          return [] unless @game.started?

          Nokogiri::XML(open_file('media/mobile.xml'))
            .xpath('//highlights/media')
            .sort { |a, b| a['date'] <=> b['date'] }
            .map { |media| process_media(media) }
        rescue OpenURI::HTTPError
          # I guess the file isn't there yet
          []
        end

        def highlights_list
          highlights
            .map do |highlight|
              icon = link_to '', url: "/#{highlight[:team].code}"
              text = "#{highlight[:blurb]} (#{highlight[:duration]})"
              url = highlight[:url]

              "- #{icon} #{url ? link_to(text, url: url) : text}"
            end
            .join "\n"
        end

        protected

        def process_media(media)
          url = media.at_xpath('url[@playback-scenario="FLASH_1200K_640X360"]')

          {
            team: media['team_id'].to_i == team.id ? team : opponent,
            headline: media.at_xpath('headline').text.strip,
            blurb: media.at_xpath('blurb').text.strip.gsub(/^[A-Z@]+: /, ''),
            duration: media.at_xpath('duration').text.strip.gsub(/^00:0?/, ''),
            url: (url.text.strip.gsub('1200K', '1800K') if url)
          }
        end
      end
    end
  end
end
