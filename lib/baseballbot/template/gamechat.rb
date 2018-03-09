# frozen_string_literal: true

class Baseballbot
  module Template
    class Gamechat < Base
      # This is kept here because of inheritance
      Dir[File.join(File.dirname(__FILE__), 'gamechat', '*.rb')].each do |file|
        require file
      end

      using TemplateRefinements

      include Template::Gamechat::BoxScore
      include Template::Gamechat::Game
      include Template::Gamechat::Highlights
      include Template::Gamechat::LineScore
      include Template::Gamechat::Postgame
      include Template::Gamechat::ScoringPlays
      include Template::Gamechat::Teams

      attr_reader :title, :post_id, :time, :team, :opponent

      def initialize(body:, bot:, subreddit:, game_pk:, title: '', post_id: nil)
        super(body: body, bot: bot)

        @subreddit = subreddit
        @time = subreddit.timezone
        @game_pk = game_pk

        @feed = bot.stats.live_feed game_pk

        @title = format_title title
        @post_id = post_id
      end

      def game
        raise 'Gameday is no longer being used!'
      end

      def inspect
        %(#<Baseballbot::Template::Gamechat @game_pk="#{@game_pk}">)
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
          start_time: start_time_local.strftime('%-I:%M %p'),
          # /r/baseball always displays ET
          start_time_et: start_time_et.strftime('%-I:%M %p'),
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
