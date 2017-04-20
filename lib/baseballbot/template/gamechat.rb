# frozen_string_literal: true

class Baseballbot
  module Template
    class Gamechat < Base
      Dir[File.join(File.dirname(__FILE__), 'gamechat', '*.rb')].each do |file|
        require file
      end

      GD2 = 'http://gd2.mlb.com/components/game/mlb'

      using TemplateRefinements

      include Template::Gamechat::LineScore
      include Template::Gamechat::BoxScore
      include Template::Gamechat::Highlights
      include Template::Gamechat::ScoringPlays

      attr_reader :game, :title, :post_id, :time, :team, :opponent

      def initialize(body:, bot:, subreddit:, gid:, title: '', post_id: nil)
        super(body: body, bot: bot)

        @subreddit = subreddit
        @time = subreddit.time
        @game = bot.gameday.game gid

        @team = home? ? @game.home_team : @game.away_team
        @opponent = home? ? @game.away_team : @game.home_team

        @title = format_title title
        @post_id = post_id
      end

      def inspect
        if @team
          %(#<Baseballbot::Template::Gamechat @team="#{@team.name}" @gid="#{@game.gid}">)
        else
          %(#<Baseballbot::Template::Gamechat @gid="#{@game.gid}">)
        end
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
        return true unless @subreddit.team

        @is_home ||= @game.home_team.code == @subreddit.team.code
      end

      def won?
        return unless @game.over?

        home? == (home[:runs] > away[:runs])
      end

      def lost?
        return unless @game.over?

        home? == (home[:runs] < away[:runs])
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
        return '' unless @game.started? && @game.files[:linescore]

        if @game.files[:linescore].at_xpath('//game/@outs')
          return @game.files[:linescore].xpath('//game/@outs').text.to_i
        end

        ''
      end

      def runners
        return '' unless @game.started? && @game.files[:linescore]

        rob = @game.files[:linescore].at_xpath '//game/@runner_on_base_status'

        if rob
          return [
            'Bases empty',
            'Runner on first',
            'Runner on second',
            'Runner on third',
            'First and second',
            'First and third',
            'Second and third',
            'Bases loaded'
          ][rob.text.to_i]
        end

        ''
      end

      protected

      def game_directory
        "#{GD2}/year_%Y/month_%m/day_%d/gid_#{@game.gid}"
      end

      def open_file(path)
        open @game.date.strftime "#{game_directory}/#{path}"
      end

      def format_title(title)
        title = time.strftime title

        # No interpolations? Great!
        return title unless title.include? '%{'

        local_start_time = home? ? @game.home_start_time : @game.away_start_time
        linescore = @game.files[:linescore]

        format title,
               home_city: @game.home_team.city,
               home_name: @game.home_team.name,
               home_record: @game.home_record.join('-'),
               home_pitcher: linescore.xpath(
                 '//game/home_probable_pitcher/@last_name'
               ).text,
               home_runs: @game.score[0],
               away_city: @game.away_team.city,
               away_name: @game.away_team.name,
               away_record: @game.away_record.join('-'),
               away_pitcher: linescore.xpath(
                 '//game/away_probable_pitcher/@last_name'
               ).text,
               away_runs: @game.score[1],
               start_time: local_start_time,
               # /r/baseball always displays ET
               start_time_et: linescore.xpath('//game/@first_pitch_et').text,
               # Postseason
               series_game: linescore.xpath('//game/@description').text,
               home_wins: linescore.xpath('//game/@home_wins').text,
               away_wins: linescore.xpath('//game/@away_wins').text
      end
    end
  end
end
