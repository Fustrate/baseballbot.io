class Baseballbot
  module Template
    class Gamechat
      module Highlights
        def highlights
          highlights = []

          return highlights unless @game.started?

          data = Nokogiri::XML open_file('media/highlights.xml')

          data.xpath('//highlights/media')
            .sort { |a, b| a['date'] <=> b['date'] }
            .each do |media|
              url = media.at_xpath('url')

              highlights << {
                team: media['team_id'].to_i == team.id ? team : opponent,
                headline: media.at_xpath('headline').text.strip,
                blurb: media.at_xpath('blurb').text.strip
                  .gsub(/^[A-Z@]+: /, ''),
                duration: media.at_xpath('duration').text.strip
                  .gsub(/^00:0?/, ''),
                url: (url.text.strip if url)
              }
            end

          highlights
        rescue OpenURI::HTTPError
          # I guess the file isn't there yet
          []
        end

        def highlights_list
          list = []

          highlights.each do |highlight|
            icon = link_to '', url: "/#{highlight[:team].code}"
            text = "#{highlight[:blurb]} (#{highlight[:duration]})"
            url = highlight[:url]

            list << "- #{icon} #{url ? link_to(text, url: url) : text}"
          end

          list.join "\n"
        end
      end
    end
  end
end
