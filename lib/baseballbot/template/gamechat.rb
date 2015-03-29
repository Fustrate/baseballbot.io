class Baseballbot
  module Template
    class Gamechat < Base
      using TemplateRefinements

      BASE_URL = 'http://gd2.mlb.com/components/game/mlb'

      attr_reader :game, :title

      def initialize(body:, bot:, subreddit:, gid:, title:)
        super(body: body, bot: bot)

        @subreddit = subreddit
        @team = subreddit.team
        @game = bot.gameday.game gid
        @title = format_title title
      end

      def inspect
        %(#<Baseballbot::Template::Gamechat @team="#{@team.name}" @gid="#{@game.gid}">)
      end

      def player_url(id)
        "http://mlb.mlb.com/team/player.jsp?player_id=#{id}"
      end

      def pitcher_line(node)
        name = "#{node.xpath('useName').text} #{node.xpath('lastName').text}"

        format '[%{name}](%{url}) (%{wins}-%{losses}, %{era} ERA)',
               name: name,
               url: player_url(node.xpath('player_id').text),
               wins: node.xpath('wins').text,
               losses: node.xpath('losses').text,
               era: node.xpath('era').text
      end

      def home?
        @is_home ||= @game.home_team.code == @team.code
      end

      def won?
        return unless @game.over?

        home? == (home[:runs] > away[:runs])
      end

      def lost?
        return unless @game.over?

        home? == (home[:runs] < away[:runs])
      end

      def team
        @team ||= home? ? @game.home_team : @game.away_team
      end

      def opponent
        @opponent ||= home? ? @game.away_team : @game.home_team
      end

      def home
        unless @game.started? && @game.boxscore
          return {
            runs: 0,
            hits: 0,
            errors: 0
          }
        end

        rhe = @game.boxscore.at_xpath '//boxscore/linescore'

        {
          runs: rhe['home_team_runs'].to_i,
          hits: rhe['home_team_hits'].to_i,
          errors: rhe['home_team_errors'].to_i
        }
      end

      def away
        unless @game.started? && @game.boxscore
          return {
            runs: 0,
            hits: 0,
            errors: 0
          }
        end

        rhe = @game.boxscore.at_xpath '//boxscore/linescore'

        {
          runs: rhe['away_team_runs'].to_i,
          hits: rhe['away_team_hits'].to_i,
          errors: rhe['away_team_errors'].to_i
        }
      end

      def lines
        lines = [[nil] * 9, [nil] * 9]

        return lines unless @game.started? && @game.boxscore

        bs = @game.boxscore

        bs.xpath('//boxscore/linescore/inning_line_score').each do |inning|
          if inning['away'] && !inning['away'].empty?
            lines[0][inning['inning'].to_i - 1] = inning['away']

            # In case of extra innings
            lines[1][inning['inning'].to_i - 1] = nil
          end

          if inning['home'] && !inning['home'].empty?
            lines[1][inning['inning'].to_i - 1] = inning['home']
          end
        end

        lines
      end

      def batters
        if @game.started? && @game.boxscore
          bs = @game.boxscore

          xpath = '//boxscore/batting[@team_flag="%{flag}"]/batter[@bo]'

          home_batters = bs.xpath(xpath % { flag: 'home' }).to_a
          away_batters = bs.xpath(xpath % { flag: 'away' }).to_a

          batter_rows = [home_batters.length, away_batters.length].max

          home_batters += [nil] * (batter_rows - home_batters.length)
          away_batters += [nil] * (batter_rows - away_batters.length)

          home_batters.zip away_batters
        else
          []
        end
      end

      def pitchers
        if @game.started? && @game.boxscore
          bs = @game.boxscore

          xpath = '//boxscore/pitching[@team_flag="%{flag}"]/pitcher'

          home_pitchers = bs.xpath(xpath % { flag: 'home' }).to_a
          away_pitchers = bs.xpath(xpath % { flag: 'away' }).to_a

          pitcher_rows = [home_pitchers.length, away_pitchers.length].max

          home_pitchers += [nil] * (pitcher_rows - home_pitchers.length)
          away_pitchers += [nil] * (pitcher_rows - away_pitchers.length)

          home_pitchers.zip away_pitchers
        else
          []
        end
      end

      def scoring_plays
        plays = []

        return plays unless @game.started?

        data = Nokogiri::XML open_file('inning/inning_Scores.xml')

        data.xpath('//scores/score').each do |play|
          plays << {
            side:   play['top_inning'] == 'Y' ? 'T' : 'B',
            team:   play['top_inning'] == 'Y' ? opponent : team,
            inning: play['inn'],
            event:  play.at_xpath('*[@des and @score="T"]')['des'],
            score:  [play['home'].to_i, play['away'].to_i]
          }
        end

        plays
      rescue OpenURI::HTTPError
        # There's no inning_Scores.xml file right now
        []
      end

      def scoring_plays_table
        table = [
          'Inning|Event|Score',
          ':-:|-|:-:'
        ]

        scoring_plays.each do |event|
          score = if event[:side] == 'T'
                    "#{ event[:score][0] }-#{ bold event[:score][1] }"
                  else
                    "#{ bold event[:score][0] }-#{ event[:score][1] }"
                  end

          table << [
            "#{ event[:inning_side] }#{ event[:inning] }",
            event[:event],
            score
          ].join('|')
        end

        table.join "\n"
      end

      def highlights
        highlights = []

        return highlights unless @game.started?

        data = Nokogiri::XML open_file('media/highlights.xml')

        data.xpath('//highlights/media')
          .sort { |a, b| a['date'] <=> b['date'] }
          .each do |media|
            highlights << {
              team: media['team_id'].to_i == team.id ? team : opponent,
              headline: media.at_xpath('headline').text.strip,
              blurb: media.at_xpath('blurb').text.strip
                .gsub(/^[A-Z@]+: /, ''),
              duration: media.at_xpath('duration').text.strip
                .gsub(/^00:0?/, ''),
              url: media.at_xpath('url').text.strip
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
          icon = link_to '', sub: subreddit(highlight[:team].code).downcase
          link = link_to "#{highlight[:blurb]} (#{highlight[:duration]})",
                         url: highlight[:url]

          list << "- #{icon} #{link}"
        end

        list.join "\n"
      end

      def inning
        return 'Postponed' if @game.postponed?

        return 'Final' if @game.over?

        if @game.in_progress?
          return @game.inning[1] + ' of the ' + @game.inning[0].to_i.ordinalize
        end

        @game.status
      rescue
        @game.status
      end

      def outs
        return '' unless @game.started? && @game.linescore

        if @game.linescore.at_xpath('//game/@outs')
          return @game.linescore.xpath('//game/@outs').text.to_i
        end

        ''
      end

      def runners
        return '' unless @game.started? && @game.linescore

        rob = @game.linescore.at_xpath '//game/@runner_on_base_status'

        if rob
          return [
            'Bases empty',
            'Runner on first',
            'Runner on second',
            'Runner on third',
            'First and second',
            'First and third',
            'Second and third',
            'Bases loaded',
          ][rob.text.to_i]
        end

        ''
      end

      def line_score
        [
          " |#{ (1..(lines[0].count)).to_a.join('|') }|R|H|E",
          ":-:|#{ (':-:|' * lines[0].count) }:-:|:-:|:-:",
          "[#{ game.away_team.code }](/#{ game.away_team.code })|" \
            "#{ lines[0].join('|') }|#{ bold away[:runs] }|" \
            "#{ bold away[:hits] }|#{ bold away[:errors] }",
          "[#{ game.home_team.code }](/#{ game.home_team.code })|" \
            "#{ lines[1].join('|') }|#{ bold home[:runs] }|" \
            "#{ bold home[:hits] }|#{ bold home[:errors] }"
        ].join "\n"
      end

      def line_score_status
        if game.over?
          'Final'
        elsif runners.empty?
          "#{outs} #{outs == 1 ? 'Out' : 'Outs'}, #{inning}"
        else
          "#{runners}, #{outs} #{outs == 1 ? 'Out' : 'Outs'}, #{inning}"
        end
      end

      def timestamp(action, hour_offset: 0)
        adjusted_time = Time.now + hour_offset * 3600

        "*#{action} at #{adjusted_time.strftime '%-I:%M %p'}.*"
      end

      def batter_row(batter)
        return ' ||||||||' unless batter

        spacer = '[](/spacer)' if batter['bo'].to_i % 100 > 0
        url = link_to batter['name'], url: player_url(batter['id'])

        [
          bold(batter['pos']),
          "#{spacer}#{url}",
          batter['ab'],
          batter['r'],
          batter['h'],
          batter['rbi'],
          batter['bb'],
          batter['so'],
          batter['avg']
        ].join '|'
      end

      def pitcher_row(pitcher)
        return ' ||||||||' unless pitcher

        game_score = pitcher['game_score']

        [
          link_to(pitcher['name'],
                  url: player_url(pitcher['id']),
                  title: game_score),
          "#{pitcher['out'].to_i / 3}.#{pitcher['out'].to_i % 3}",
          pitcher['h'],
          pitcher['r'],
          pitcher['er'],
          pitcher['bb'],
          pitcher['so'],
          "#{pitcher['np']}-#{pitcher['s']}",
          pitcher['era']
        ].join '|'
      end

      protected

      def game_directory
        "#{BASE_URL}/year_%Y/month_%m/day_%d/gid_#{@game.gid}"
      end

      def open_file(path)
        open @game.date.strftime "#{game_directory}/#{path}"
      end

      def format_title(title)
        title = Time.now.strftime title
        game_number = @game.gamecenter.xpath('//game/@series-game-number').text

        format title,
               game_number: game_number,
               home_city: @game.home_team.city,
               home_name: @game.home_team.name,
               home_record: @game.home_record.join('-'),
               home_pitcher: @game.linescore.xpath(
                 '//game/home_probable_pitcher/@last_name'
               ).text,
               away_city: @game.away_team.city,
               away_name: @game.away_team.name,
               away_record: @game.away_record.join('-'),
               away_pitcher: @game.linescore.xpath(
                 '//game/away_probable_pitcher/@last_name'
               ).text,
               start_time: home? ? @game.home_start_time : @game.away_start_time
      end
    end
  end
end
