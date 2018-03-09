# frozen_string_literal: true

Dir[File.join(File.dirname(__FILE__), 'gamechat', '*.rb')].each do |file|
  require file
end

class Baseballbot
  module Template
    class Gamechat < Base
      GDX = 'http://gdx.mlb.com/components/game/mlb'

      using TemplateRefinements

      include Template::Gamechat::BoxScore
      include Template::Gamechat::Game
      include Template::Gamechat::Highlights
      include Template::Gamechat::LineScore
      include Template::Gamechat::Postgame
      include Template::Gamechat::ScoringPlays
      include Template::Gamechat::Teams

      attr_reader :game, :title, :post_id, :time, :team, :opponent

      def initialize(body:, bot:, subreddit:, gid:, game_pk:, title: '', post_id: nil)
        super(body: body, bot: bot)

        @subreddit = subreddit
        @time = subreddit.timezone
        @game = bot.gameday.game gid

        @team = home? ? @game.home_team : @game.away_team
        @opponent = home? ? @game.away_team : @game.home_team

        @title = format_title title
        @post_id = post_id

        @feed = bot.stats.live_feed game_pk
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

      def player_link(player, title: nil)
        link_to(
          player['name']['boxname'],
          url: player_url(player['id']),
          title: title
        )
      end

      def pitcher_line(node)
        name = "#{node.xpath('useName').text} #{node.xpath('lastName').text}"

        format '[%<name>s](%<url>s) (%<wins>d-%<losses>d, %0.2<era>f ERA)',
               name: name,
               url: player_url(node.xpath('player_id').text),
               wins: node.xpath('wins').text,
               losses: node.xpath('losses').text,
               era: node.xpath('era').text.to_f
      end

      protected

      def format_title(title)
        title = time.strftime title

        # No interpolations? Great!
        return title unless title.match?(/%[{<]/)

        format title, title_interpolations
      end

      # rubocop:disable Metrics/MethodLength
      def title_interpolations
        {
          home_city: @feed['gameData']['teams']['home']['locationName'],
          home_name: @feed['gameData']['teams']['home']['teamName'],
          home_record: home_record,
          home_pitcher: probable_home_starter['boxscoreName'],
          home_runs: home_rhe['runs'],
          away_city: @feed['gameData']['teams']['away']['locationName'],
          away_name: @feed['gameData']['teams']['away']['teamName'],
          away_record: away_record,
          away_pitcher: probable_away_starter['boxscoreName'],
          away_runs: away_rhe['runs'],
          start_time: start_time_local,
          # /r/baseball always displays ET
          start_time_et: start_time_et,
          # Postseason
          series_game: '?', # @linescore.xpath('//game/@description').text,
          home_wins: '?',   # @linescore.xpath('//game/@home_wins').text,
          away_wins: '?'    # @linescore.xpath('//game/@away_wins').text
        }
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
